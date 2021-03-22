#Requires -Version 3
<#
	.SYNOPSIS
		Lot of tools written in pure powershell to connect with SQL Server!
	
	.DESCRIPTION			
		This module contains useful cmdlets allow you interacts with SqlServer and deeper level!
		
		The main advantage of this module is that it was written with just powershell code.
		It means, you dont need any external DLL to run yet.
		The cons, is that it not optimial for high perofmrance read.
		
		If you want read lot of data from a sql instance, use another module, like SqlServer, or slqps, from microsofft.
		But, if want consume few data from server, it can be a good alternatives.
		
		Begginer start:
			
			The simple form to run a query is using Invoke-SqlServerClient cmdlet:
			
			Invoke-SqlServerClient -Serverinstance SomeServer\SomeINstance -sql "SELECT a = somehting"
			
			This will use windows authentication!
			you can use -file to specify a file.
			you can use -User and -Password to user sql credentials.
			Check Invoke-SqlServerClient to more help!
			It will return all rows, of ll resultsets...

		Advanced way:
			SqlClient with provide lot of useful mechanism to allow you control many aspects of connectin and row fetching.
			FOr example,  you can open connections with Conenct-SqlSEver
				$conn = Connect-SqlServer -ServerInstance Int\Name;
				
			Then, you can start request on this connections (both asnc and sync).
				$MyRequest = Start-SqlRequest -connection $conn -sql "select * from sys.databases";
				
			Then, you can fetch row by row...
				$NextRow = Get-SqlServerNextRow $MyRequest
				
			OR, you can fetch all rows once!
				$RemainingRows = Get-SqlServerNextRow $MyRequest -Full
				
			Get-SqlServerNextRow returns a object containg following data:
				HasData = 
				
		Async Processing
			
			SqlClient makes the work of do async request more easy!
			The simple thing you need to is:
				1 - Open connection
				2 - Start async request
				3 - Issue async fetchs (reads from server)
			
			For starting a new request, you must use the Start-SqlRequest.
			It retuns a object that represent current batch request you send yo srver.!
			This object contains two important properties: finished and running.
				
				running property means request is running and you is waiting data from it.
				When working with async requests, you must check this.
				If true, means that more data can be avialable...
				the other
				
				finished proerty means request finished and all data was fetch from server (erros, messages and rows).
			
			Follwoing demonstrate some situations on this proeprties:
			
				1) Sync fetches  
					
					--> You issue a request synchronous... 
						At this oint you will be blocked up to sql return something.
					
						$r = Start-SqlRequest
						-- blocked up to some data avialable ---
					
					--> Finished will be false, because you not ask anything to be fetced yet 
						Independlty of any data be returned or now, request is onsidered as "finished" only when you read all data, at least, once.
						(to check if there are some data).
					
						$r.finished;  
					
						
					--> Running will be false, because sql already ran request and produced some result.
						This means sql waiting consume local buffers of data or already copied all result to local buffer.
					
						$r.running;	 

					
					--> This is how you ask to some data from server.
						This will cause we read data from local buffers, or ask next data to server.
						You can be blocked if there more data to be read from server.
						Sql Server will send as much data as possible based on PacketSize.
						When buffers gets full, it will wait you ask more data (you will see ASYNC_NETWORK_IO on server side).
					
						$NextRow = Get-SqlServerNextRow $r 
						--- blocked ---
						
					--> At this point, finished is false (becase can exist more data to be fetched).
						running is false, because it ysnc, then, after it returns, means server not running anything.
						
					--> Then, suppose you arrives last set of data to be read from server!
						
					
						$NextRow = Get-SqlServerNextRow $r
						--- blocked ---
					
					--> If no more data avialable, $NextRow will contains a HasData property as false.
						Also, $r.finished will be true, meaning all data (rows, erros and warningS) was read from server.
						running will be false.
						At this point you can safelly stop to request more data, because there more anything.
					
				
			2) Assync fetches 				
			
				Async request change a little way how you must use th objects.
				
					--> You issue a request aasynchronous... 
						At this point, we will send request to sql and return imediatelly.
						While Sql Server runs query, we can do otherthings...
					
						$r = Start-SqlRequest -Async

					
					--> Finished will be false als, like sync.. 
					
						$r.finished;  
					
						
					--> Running will be true, unlike sync.
						This indicates that request is being run by Sql Server.
					
						$r.running;	 

					
					--> To check if request already finished, we still using Get-SqlNextRow.
						IT contains all necessary logic to check if async request finished or not.
						Note i've used the 'Async' parameter here too. After aysnc request completes, this
						force Get-SqlServerNextRow to retrieve each row async way too. IF you not use them, then
						after request ends, it will do a sync fetch. Then, you  must use it if you keep feth async.
					
						$NextRow = Get-SqlServerNextRow $r -Async
						
					--> At this point, finished is false yet
						But, $r.running can keep true, or be changed to false, depending of result.7
						If true, means request keep runing, and you must wait.
						But, some data can be returned, and you must keep cheking $NextRow to see if some data was returned.
						
						
					--> Then, suppose you arrives last set of data to be read from server!
						
					
						$NextRow = Get-SqlServerNextRow $r -Async
					
					--> This wokr like sync. If sql server not ended ran request, then running will be true.
						You must keep calling Get-SqlServerNextRow.
						When sql servers ends request and procuding alst sort of data, then the call of Get-SqlServerNextRow
						will result in some data plus both $r.finished and $r.running set to false
						
#>

<#
	.SYNOPSIS
		Opens connections with Sql Server
		
	.DESCRIPTION 
		Opens a connections with some sql server instance
#>
function Connect-SqlServer {
	[CmdletBinding()]
	param(
		$serverInstance = $null
		,$database = "master"
		,$User
		,$Password
		,[string[]]$ExtraKeywords = @()
		,$appName = $null
		,[switch]$NoPooling
		,[switch]$UsePsEvents
		,$ConnectionTimeout = $null
		,$FailoverPartner = $null
	)
	
							
	write-verbose "The server instance will be: $($serverInstance)"

	write-verbose "The database will be: $($database)"
	
	$SqlConnection  = New-Object PsObject -Prop @{
									#Raw sql client connection 
									RawConnection 		= $null

									
									#Connections parameters
									params = @($Args + $PSBoundParameters)
									
									
									#Event subcriptio to catch erros...
									EventSubcription	= $null
									#Queeu
									EventQueue 		= @();
									EventQueueMode		= "Q" # Q,PSE
							}
	
	$AuthString = "Integrated Security=True"
	$appName = $this.appName
	
	if($User) {
		write-verbose "The logon user will be: $User"
		write-verbose "The logon pass will be: $Password"
	
		$AuthString = "User=$User;Password=$Password"
	}
	
	if(!$appName){
		$appName = "mssql.ps1"
	}
	
	write-verbose "The app name will be: $appName"
	
	$ConnectionStringParts = @(
		"Server=$ServerInstance"
		"Database=$database"
		$AuthString
		"APP=$appName"
	)
	
	if($FailoverPartner){
		$ConnectionStringParts += 'Failover Partner='+$FailoverPartner;
	}
	
	
	if(-not($ConnectionTimeout -eq $null)){
		$ConnectionStringParts += 'Connection Timeout='+$ConnectionTimeout
	}
	
	if($NoPooling){
		$ConnectionStringParts += "Pooling=false"
	}
	
	if($ExtraKeywords){
		$ExtraKeywords | %{
			$ConnectionStringParts += ($_ -split ";");
		}
	}
	
	
	#RRG_EDIT: Changed connection string direct to Join form...
	# "Server=$ServerInstance;Database=$Database;Integrated Security=True;App=$App"
	$NewConex = New-Object System.Data.SqlClient.SqlConnection
	$NewConex.ConnectionString = $ConnectionStringParts -Join ";" 
	$SqlConnection.RawConnection  = $NewConex;
	
	$NewConex.FireInfoMessageEventOnUserErrors = $true;

	
	Import-SqlInfoEventHandler;
	
	#This is a "safe" way to process event requests.
	if($UsePsEvents){
		$SqlConnection.EventQueueMode = "PSE";
		#We will not use the this method BY DEFAULT because this seems not preserve order which SqlConnections raises events.
		#Looking at source code pwoershell, i guess it process events using many threads, so, this can change original order of events.
		
		
		#Register event to catch results...
		$InfoMessageSubcriber = Register-ObjectEvent -InputObject $NewConex -EventName "InfoMessage";
		#Get the event subcription...
		$EventSubscription = Get-EventSubscriber | ? {$_.SourceObject.Equals($NewConex) -and $_.EventName -eq 'InfoMessage'};
		$SqlConnection.EventSubcription = $EventSubscription;
	} else {
		$e = new-Object SqlInfoEventHandler($NewConex)
		$SqlConnection.EventQueue = $e.GetEventQueue();
	}

	

	
	write-verbose "The final connection string is: $($NewConex.ConnectionString ) "
	
	try {
		write-verbose "Opening connections..."
		$NewConex.Open()
		
		write-verbose "Returning..."
		return $SqlConnection;
	} catch {
		write-verbose "Some error while connect to server..."
		if($NewConex){
			$NewConex.Dispose()
		}
		
		#Destroy event...

		write-verbose "Removing InfoMessage subscriptions..."
		if($EventSubscription){
			$EventSubscription | %{
					UnRegister-Event -SubscriptionId $_.SubscriptionId 
			}
		}
		
		throw ($_.Exception.GetBaseException())
	}
	
}

<#
	.SYNOPSIS
		import the class type used to handle queue.
		
	.DESCRIPTION 
		import the class type used to handle queue.
#>
function Import-SqlInfoEventHandler {
	[CmdLetBinding()]
	param($connection)
	
	if($SqlInfoEventHandler){
		write-verbose "Import-SqlInfoEventHandler: Already imported"
		return;
	}
	
	$SqlInfoEventHandlerSource = "
		using System;
		using System.Data;
		using System.Data.SqlClient;
		using System.Collections;
		using System.Collections.Generic;
		
		
		public class SqlInfoEventHandler {
			private Queue<InfoMessageData> EventQueue = new Queue<InfoMessageData>();
			private int EventId = 1;
			
			public SqlInfoEventHandler(SqlConnection c){
				c.InfoMessage += new SqlInfoMessageEventHandler(AddEventQueue); 
			}
			
			public Queue<InfoMessageData> GetEventQueue(){
				return this.EventQueue;
			}
			
			public void AddEventQueue(object sender, SqlInfoMessageEventArgs args){
				var ev 		= new InfoMessageData();
				ev.sender 	= sender;
				ev.args 	= args;
				ev.EventId	= this.EventId++;
				this.EventQueue.Enqueue(ev);
			}
		}
		
		public class InfoMessageData {
			public 	int	   EventId;
			public  object sender;
			public 	SqlInfoMessageEventArgs args;
		}
	"

	write-verbose "Import-SqlInfoEventHandler: Importing"
	$SqlInfoEventHandler = Add-Type -TypeDefinition $SqlInfoEventHandlerSource -ReferencedAssemblies 'System.Data.dll';
}

<#
	.SYNOPSIS
		Ends a connections with SQL Server
		
	.DESCRIPTION 
		Ends a connections with SQL Server, opened with Connect-SQL
#>
function Disconnect-SqlServer {
	param($connection)
	
	$conn  = $connection.RawConnection;
	$EventSubcription = $connection.EventSubcription
	
	if($conn)
	{
		write-verbose "The  connection object will be disposed."
		$conn.Dispose()
		
		write-verbose "The  session property will be null"
		$conn = $null	
	} else {
		write-verbose "No connection on session object available to ending."
	}
	
	if($EventSubscription){
		write-verbose "Removing InfoMessage subscriptions..."
		if($EventSubscription){
			$EventSubscription | %{
					UnRegister-Event -SubscriptionId $_.SubscriptionId 
			}
		}
	}
}

<#
	.SYNOPSIS
		Send request in some connection
		
	.DESCRIPTION 
		Runs SQL on some connections, or open a new connection if no previouas is informed!
#>
function Start-SqlRequest {
	param($connection, $sql, $QueryTimeout = 0,[switch]$Async)
	
	$c 	= $connection.RawConnection;
	
	$request	= New-Object PsObject -Prop @{
						connection 			= $connection
						ReaderParser		= $null
						CommandTSQL			= $null	

						#Processed all resultsets?
						finished			= $false
						
						#Indicates that last resultset was processed.
						#This means that current resultset to be processes is "fake" resultset
						#only to get remaiing data returned by server, like messahes.
						LastResultSet		= $false;
						
						#Porint to current resultset!
						CurrentResultSet	= $null
						ResultSetPosition	= 0
						
						#If is async, this will contains async task.
						AsyncTask = $null
						
						#Indicates async read is in course...
						running = $false
						nexting	= $false #inidcates waiting for a resulset in course...
					}
		
	if(!$sql){
		throw "EMPTY_SQL";
	}
	

	write-verbose "Creating the command object..."
	$commandTSQL = $c.CreateCommand()
	$request.CommandTSQL = $commandTSQL;

	write-verbose "Setting the query timeout for : $QueryTimeout"
	$commandTSQL.CommandTimeout = $QueryTimeout
	
	write-verbose "Creating reader parser..."
	#This is a workaround to use SqlData reader in powershell V2...
	#A behavior in powershell cause it call the enumerator of some parameters that are passed.
	#With SqlDataReader, if this happens, the result returned are lost...
	#Thus, using this object, we can "protect" the sqldata reader in some property of objct and pass object between calls...
	$ReaderParser = New-SqlReaderParser
	$request.ReaderParser = $ReaderParser;
	
	write-verbose "Setting the SQL script to: $sql"
	$commandTSQL.CommandText = $sql

	#Send exexecute request to SQL Server... This will block...
	$result = $null;
	write-verbose "Executing the command on the connection..."
	if($Async){
		$request.AsyncTask 	= $commandTSQL.ExecuteReaderAsync()
		$request.running	= $true;
		$request.nexting	= $true;
	} else {
		$ReaderParser.reader = $commandTSQL.ExecuteReader()
	}
		


	#If not result, reader set to false...
	if(!$ReaderParser.reader){
		$ReaderParser.hadNext = $false;
	}
	
	#At this, SQL waiting us to ask resultset and rows... work f this function ends...		
	
	return $request;
	
}


<#
	.SYNOPSIS
		Stop request, dealoocatng all objects
		
	.DESCRIPTION 
		Stop request, dealoocatng all objects
#>
function Close-SqlRequest {
	[CmdletBinding()]
	param($SqlRequest)
	
		
	#Objects already built when request was created...
	$commandTSQL 		= $SqlRequest.commandTSQL;
	$ReaderParser 		= $SqlRequest.ReaderParser;

	#Consume all remaining events...
	write-verbose "Stop-SqlRequest: removing remaining event messages/errors"
	$evs = Get-SqlServerMessages $SqlRequest;
	
	if($ReaderParser.reader)
	{
		write-verbose "Disposing SqlDataReader object..."
		$ReaderParser.reader.Dispose()
	}
	
	if($commandTSQL)
	{
		write-verbose "Disposing Command object..."
		$commandTSQL.Dispose()
	}
	
	if($ReaderParser){
		$ReaderParser  = $null;
	}
	
	

	$SqlRequest.finished = $true;
}

<#

#>
function Test-SqlRequestCompleted {
	param($SqlRequest)
	
	if(!$SqlRequest.nexting -and !$SqlRequest.running){
		return $true;
	}
	
	if($SqlRequest.AsyncTask.IsCompleted){
			
			$Exception = $SqlRequest.AsyncTask.Exception;
			
			if($Exception){
				write-verbose "Some error throwed by SqlRequest"
				#Check if base exception is SQL Exceptions...
				$Bex = $Exception.GetBaseException();
				
				throw $Bex;
			}
			
			$SqlRequest.ReaderParser.reader = $SqlRequest.AsyncTask.Result;
			$SqlRequest.running = $false;
			$SqlRequest.nexting = $false;
			return $true;
	} else {
		return $false;
	}
}

<#
	Wait some sql data!
#>
function Wait-SqlRequestCompleted {
	param($SqlRequest, $MaxWaitTime = 1000)
	
	$WaitsHandles = @(	
		$SqlRequest.AsyncTask
		$SqlRequest.ReaderParser.AsyncHandle
	)
	
	if($WaitsHandles){
		$i = $WaitsHandles.count;
		$PerHandleTime = $MaxWaitTime/$WaitsHandles.count;
		
		while($i--){
			$WaitHandle = $WaitsHandles[$i];
			
			if($WaitHandle -eq $null){
				continue;
			}
			
			try {
				$Result = $WaitHandle.wait($MaxWaitTime);
			} catch {
				write-warning "Error while waiting query results...";
				return $true;
			}
			
			if($Result){
				return $true;
			}
		}
		
		
	}
	
	return $false;
}


<#
	.SYNOPSIS
		Get next resultset available in some request
		
	.DESCRIPTION 
		Get next resultset available in some request, and by default, load all rows, errors and messages.
#>
function Get-SqlServerNextResultset {
	[CmdletBinding()]
	param(
	
		$SqlRequest
		
		,#Tell to the cmdlet that user want load all rows of this resulttime at this time.
			[switch]$Full
			
		,#get async
			[switch]$Async
	)

 
		
	#Objects already built when request was created...
	$c 					= $SqlRequest.connection.RawConnection;
	$commandTSQL 		= $SqlRequest.commandTSQL;
	$EventSubscription 	= $SqlRequest.connection.EventSubcription;
	$ReaderParser 		= $SqlRequest.ReaderParser;
	
	if($SqlRequest.running -and $SqlRequest.ResultSetPosition -eq 0){
		#Test if request completed!
		if(-not(Test-SqlRequestCompleted $SqlRequest)){
			write-verbose "Request running and no result available yet...";
			return;
		}
	}
	
	#If request fully processed, then ends!
	if($SqlRequest.finished){
		write-verbose "Request already finished";
		return;
	}
	
	try {
	
		#If we are in last resultset, then no exist next!
		#Just flag as finished. No more processing!
		if($SqlRequest.LastResultSet){
			$SqlRequest.finished = $true;
			return;
		}
	
		#Ask reader to advance to next resultset!
		$NextRSParams = @{
			'ReaderObject' = $ReaderParser
		}
		
		if($Async){
			$NextRSParams['Async'] = $true;
		}
		
		$NextReaderRS  = Get-SqlReaderNextResultset @NextRSParams;
		
		#If net resultset is being async...
		if($ReaderParser.nexting){
			write-verbose "Next resultset being processed async... returning...";
			$SqlRequest.running = $true;
			return;
		} else {
			$SqlRequest.running = $false;
		}
		
		#Set request pointer to the new resultset...
		$SqlRequest.CurrentResultSet = $NextReaderRS;
		$SqlRequest.ResultSetPosition++;
		
		if(!$NextReaderRS){	
			#We are in last resultset mode...
			$SqlRequest.LastResultSet = $true;
		}
		
		#If manual fetch, nothing to do also.
		#USer must use Get-SqlNextRow to fetch rows manually...
		if(!$Full){
			return;
		}
		
		#By default, in addition to advance to next resultset, read all rows, messages and errors of current resultset!
		write-verbose "Get-SqlServerNextResultset: Fetching all rows"
		$Resultset =  Get-SqlServerNextRow $SqlRequest -Full;
	} finally {
		#If request done, then do cleanup...
		if($SqlRequest.finished){
			Close-SqlRequest $SqlRequest;
		}
	}
	
	return $Resultset;
	
}

<#
	.SYNOPSIS
		Get next row available in current result set
		
	.DESCRIPTION 
		Get next row available in current result set. TO advance to next, use Get-SqlServerNextResultset
#>
function Get-SqlServerNextRow {
	[CmdletBinding()]
	param(
	
		$SqlRequest
		
		,#Retrieve all rows one time
			[switch]$Full
			
		,#Get async
			[switch]$Async
			
		,#Auto skip to next resultset!
			[switch]$NoNextResultset
	)
	
	#Object that we will return.
	$Resultset = New-Object PsObject -Prop @{
							results 	= $null
							messages	= @()
							hasData		= $false
					}
					
					
	#Objects wee need, to interact with request...
	$c 	= $SqlRequest.connection.RawConnection;
	
	# if last resultset was processed, means no more resultset to process.
	if($SqlRequest.finished){
		write-verbose  "Get-SqlServerNextRow: Request already finished"
		return;
	}

	function GetUpdatedMessages {
		#Get the available messages!
		$Messages = Get-SqlServerMessages $SqlRequest;
		if($Messages.all){
			$Resultset.messages += $Messages;
			$Resultset.hasData = $true;
		}
	}

	#Get a update messages or errors!
	GetUpdatedMessages
	
	#Parameters to  next resultset
	$NextResultsetParams = @{
		'SqlRequest' 	= $SqlRequest
		'Async' 		= $Async
	}
	

	# if last resultset was processed, just process last one!
	if($SqlRequest.LastResultSet){
		if(!$NoNextResultset){
			write-verbose "Get-SqlServerNextRow: 	Last resultset, advancing to end..."
			Get-SqlServerNextResultset @NextResultsetParams;
		}
		return $Resultset;
	}
	
	#If request unning, 
	if($SqlRequest.ResultSetPosition -eq 0){
		write-verbose "Get-SqlServerNextRow: 	Positining on first resultset..."
		Get-SqlServerNextResultset @NextResultsetParams;
		if($SqlRequest.running){
			GetUpdatedMessages
			return $Resultset;
		}
	}
	
	if($SqlRequest.nexting){
		return $Resultset;
	}
	
	#We have a valid resultset?
	if(!$SqlRequest.CurrentResultSet){
		throw "GETNEXTSQLROW: Current resultset empty. Use Get-SqlServerNextResultset to advance to next resultset."
	}
	
	#We trust on Get-SqlReaderNextRow to retrive rows. Must prepare parameters.
	#Parameters to be passed to SqlReaderNext row cmdlet.
	$SqlReaderNextRowParams = @{
			'Resultset'  = $SqlRequest.CurrentResultSet
		}
		
	#If user specified full, we will read all full rows one time!
	#Otherwise, cmdlet will output a result per row.
	if($Full){
		$SqlReaderNextRowParams['Full'] = $true;
	}	
	
	if($Async){
		$SqlReaderNextRowParams['Async'] = $true;
	}
	

	write-verbose " Get-SqlServerNextRow: Fetching row(s)";
		
	#Ask the row or rows to the our current reader, in current resultset.
	$AllRows =  Get-SqlReaderNextRow @SqlReaderNextRowParams 
	GetUpdatedMessages;
	
	if($SqlRequest.CurrentResultSet.reading){
		$SqlRequest.running = $true;
	} else {
		$SqlRequest.running = $false;
		if($NoNextResultset){
			write-verbose " Get-SqlServerNextRow: Next resulset will not got automatically. NoNextResultset";
		} elseif($SqlRequest.CurrentResultSet.LastRowRead){
			write-verbose " Get-SqlServerNextRow: LastRow was read. Auto advancing to next resultset...";
			Get-SqlServerNextResultset @NextResultsetParams;
		}
	}
	
	$Resultset.results = $AllRows;
	if($AllRows){
		$Resultset.hasData = $true;
	}

	
	return $Resultset;
}

<#
	.SYNOPSIS
		Get current messages and errors available in connection
		
	.DESCRIPTION 
		Get current messages and errors available in connection
#>
function Get-SqlServerMessages {
	param(
		$SqlRequest
	)
	
	$EvQueue 	= $SqlRequest.connection.EventQueue;
	$QueueMode 	= $SqlRequest.connection.EventQueueMode;
	
	$Results = @{
		errors 		= @()
		messages	= @()
		all			= @()
	}
	
	function GetQueueData {
		param(
			$Errors
		)
		
		$Errors | %{
			$_ | Add-Member -Type noteproperty -Name MessageType -Value $null -force;
			
			if($_.class -le 10){
				$Results.messages += $_;
				$_.MessageType = "message";
			} else {
				$Results.errors += $_;
				$_.MessageType = "error";
			}
			$Results.all += $_;
		}
	}
	
	#Before ends, check if there are some error generated by SqlServer on connection event...
	write-verbose "Get-SqlServerMessages: Getting remaining events..."
	if($QueueMode -eq "Q"){
		write-verbose "Get-SqlServerMessages: 	Using event Queue mode..."
		while($EvQueue.count){	
			$Item = $EvQueue.dequeue();
			$EventArguments = $Item.args;
			GetQueueData @($EventArguments.errors);
		}
	} else {
		write-verbose "Get-SqlServerMessages: 	Using powershell event mode..."
		$c = $SqlRequest.connection.RawConnection;
		Get-Event | ? {$_.Sender.Equals($c)} | %{
					$EventArguments = $_.SourceEventArgs -as [System.Data.SqlClient.SqlInfoMessageEventArgs];
					GetQueueData @($EventArguments.errors);
					Remove-Event -EventIdentifier $_.EventIdentifier;
			}
	}

	write-verbose "	Get-SqlServerMessages: Got $($Results.all.count) messages event"
		
	return $Results;
}


<#
	.SYNOPSIS
		Connects, runs command, and disconnect! All asynchrnously
		
	.DESCRIPTION 
		Runs SQL on some connections, or open a new connection if no previouas is informed!
#>
function Invoke-Sql {
	[CmdletBinding()]
	param(
		 $SQL
		,$ServerInstance = $null
		,$database = "master"
		,$User
		,$Password
		,[string[]]$ExtraKeywords = @()
		,$appName = $null
		,[switch]$NoPooling
		,$QueryTimeout = 0
		,$file
		,[switch]$async
		,[switch]$UsePsEvent
		,$connection
		,[switch]$NoWarning
	)
	
	if($file){
		if(-not(Test-path $file)){
			throw "INVOKESQLSERVER_SQLFILE_NOTFOUND: $file";
		}
		
		$sql = Get-Content (Resolve-Path $file) -Raw;
	}	
	
	#Opens the connection!
	$ConexParams = @{
		ServerInstance 	= $ServerInstance
		database 		= $Database
		User			= $User
		Password		= $Password
		ExtraKeywords	= $ExtraKeywords
		appName 		= $appName
		NoPooling		= $NoPooling
	}
	
	if($UsePsEvent){
		$ConexParams['UsePsEvents'] = $true;
	}
	
	$Disconnect = $false;
	
	if($connection){
		$SqlConnection = $connection;
	} else {
		$SQLConnection = Connect-SqlServer @ConexParams;
		$Disconnect = $true;
	}
	
	if($Async){
		$Disconnect = $false;
	}
	
	try {
		$BatchRequest = Start-SqlRequest -connection $SQLConnection -sql $sql -QueryTimeout $QueryTimeout -Async;
		
		#Get next resultset!
		while(!$BatchRequest.finished){
			$r = Get-SqlServerNextRow $BatchRequest -Full;
			
			if($r.hasData -and $r.messages.messages){
				if(!$NoWarning){
					$r.messages.messages | %{
						write-warning $_.message
					}
				}
			}

			if($r.hasData -and $r.messages.errors){
				$r.messages.errors | %{
					Write-Error $_.message -ErrorAction "Continue"
				}
			}
			
			if($r.results){
				write-output $r.results
			}
		}
	} finally {
		if($Disconnect){
			Disconnect-SqlServer $SqlConnection;
		}
	}

}


<#
	.SYNOPSIS
		Connects, runs command, and disconnect! All asynchrnously
		
	.DESCRIPTION 
		Runs SQL on some connections, or open a new connection if no previouas is informed!
#>
function Invoke-SqlServerClient {
	[CmdletBinding()]
	param(
		 $SQL
		,$ServerInstance = $null
		,$database = "master"
		,$User
		,$Password
		,[string[]]$ExtraKeywords = @()
		,$appName = $null
		,[switch]$NoPooling
		,$QueryTimeout = 0
		,$file
		,[switch]$UsePsEvent
		,[scriptblock]$RowScript = $null
		,$delay = 1000
		,$ConnectionTimeout = $null
		,$FailoverPartner = $null
		,$NumConnections = 1
	)
	
	if($file){
		if(-not(Test-path $file)){
			throw "INVOKESQLSERVER_SQLFILE_NOTFOUND: $file";
		}
		
		$sql = Get-Content (Resolve-Path $file) -Raw;
	}	
	
	#Opens the connection!
	$ConexParams = @{
		ServerInstance 	= $ServerInstance
		database 		= $Database
		User			= $User
		Password		= $Password
		ExtraKeywords	= $ExtraKeywords
		appName 		= $appName
		NoPooling		= $NoPooling
		ConnectionTimeout = $ConnectionTimeout
		FailoverPartner = $FailoverPartner
	}
	
	if($UsePsEvent){
		$ConexParams['UsePsEvents'] = $true;
	}
	
	
	$SQLConnection = @();
	1..$NumConnections  | %{
		$NewConnSlot = @{
				num			= $_
				connection 	= $null
				sqlrequest	= $null
				error		= $null
				resultError 	= @()
				resultMessages	= @()
				resultOutput 	= @()
			}
		$SqlConnection += $NewConnSlot;
		
		try {
			write-verbose "Creating connection $_"
			$NewConnSlot.connection = Connect-SqlServer @ConexParams
		} catch {
			if($NumConnections -eq 1){
				throw;
			}
		
			$NewConnSlot.error += $_;
		}
	}
	
	
	try {
	
		$SQLConnection  | ? { $_.connection } | %{
			$CurrentConnection = $_;
			try {
				write-verbose "Starting request on connection $($_.num)"
				$_.sqlrequest = Start-SqlRequest -connection $_.connection -sql $sql -QueryTimeout $QueryTimeout -Async;
			} catch {
				
				if($NumConnections -eq 1){
					throw;
				}
				
				$CurrentConnection.error = $_;
			}
		}
	


	
		#Get next resultset!
		while($true){
			
			$ConnNotFinished = @($SQLConnection | ? { $_.sqlrequest -and !$_.sqlrequest.finished });
			
			if(!$ConnNotFinished){
				break;
			}

			$PerConnectionDelay = $delay/$ConnNotFinished.count;
		

			$ConnNotFinished | %{
				$CurrentConnection = $_;
				
				$NextRowParams = @{
					'SqlRequest'	= $CurrentConnection.sqlrequest;
					'Full'			= $true;
					'Async'			= $false;
				}
				
				if($RowScript){
					$NextRowParams.Full = $false;
					$NextRowParams.Async = $true;
				}
				
				if($SqlConnection.count -gt 1){
					$NextRowParams.Async = $true;
				}
				
				$r = Get-SqlServerNextRow @NextRowParams;
				
				if($r.HasData){
					$r.messages.all  | %{
							
							if($_.MessageType -eq "error"){
								if($SqlConnection.count -eq 1){
									write-host "Error:" $_.message -ForegroundColor red;
								} else {
									$CurrentConnection.resultError += $_.message
								}
							} else {
								if($SqlConnection.count -eq 1){
									write-host $_.message;
								} else {
									$CurrentConnection.resultMessages += $_.message
								}
							}
							
						};
						
					if($r.results){
						if($SqlConnection.count -eq 1){
							write-output $r.results;
						} else {
							$CurrentConnection.resultOutput += $r.results;
						}	
					}
					
					if($RowScript){
						write-verbose "Invoke-SqlServerClient: Running row script on connection $($CurrentConnection.num)...";
						$scriptres = $r | % $RowScript;
						write-host ($scriptres|out-string);
					}
					
					
				}
			}
			
			if($SqlConnection.count -eq 1){
				write-verbose "Invoke-SqlServerClient: waiting results... up to $delay seconds";
				$r = Wait-SqlRequestCompleted $SqlConnection[0].sqlrequest -MaxWaitTime $delay;
			}
		}
		
		
		if($SqlConnection.count -gt 1){
			return $SqlConnection | %{ New-Object PsObject -Prop $_ };
		}
	} finally {
		$SqlConnection | %{
			Disconnect-SqlServer $_reader
		};
	}

}


##############################
#### DATA READER FUNCTIONS
#### this functions are helpers functions implementing use of SqlClient DataReader.
#### No use directly because it not handle some aspects, like errors andmessags.
####
<# 
	.SYNOPSIS	
		Creates a new data reader, to read rows from T-SQL execution.
		
	.DESCRIPTION
		#This functions create a new object that represent a data reader.
		#It main objective is allow the other *sqlserver cmdlets, to convert a SqlClient DataReader object  to Array of objects!
		#User must assign the DataReader object returned by ExecuteReader to member reader. 
		#	This is need because powershell attempts iterate when passing on parameeter.
		#	This is bad for the DataReader, because when iterate over it, we cannot go back to first results. It is like "forward only".
		#	For that, we need set the "reader" property of returned object!
#>
	Function New-SqlReaderParser {

		#Create a custom object representing our reader!
		#This is that we want return!
		$o = New-Object PsObject -Prop @{
			#This will contain the _reader object...
			reader = $null
			
			#This store the number of times that read of object was request.
			#This is number of calls to NextResult...
			#We use this to check if some resultset already returned...
			ReadCount = 0
			
			#This indicates if previous call to NextResult returned $true.
			#When this value is $false, then no more result is available to return and client can stop to requesting resultssets...
			#It must be initialize as $true, in order to make a at lear one attempt.
			hadNext = $true 
			
			#AsyncRead handle, for async operations
			AsyncHandle = $null
			
			#Indicates a pending read or net result, is on course.
			reading = $false  
			nexting	= $false
			
		}
		
		return $o;
	}


function Test-ConnectTimes {
	[CmdLetBinding()]
	param(
		$ServerInstance
		,$sql = $null
		,[switch]$Pooling
		,[string[]]$ExtraKeywords = @()
		,$AppName = 'SqlConnectionTest'
		,$User
		,$Password
		,$RepeatMs
		,$MaxExecutions
		,$ResultVariable
		,$ConnectionTimeout
	)

	$ErrorActionPreference = "Stop";
	
	$ConnectParams = @{
		ServerInstance = $ServerInstance
		User = $User
		Password = $Password
		NoPooling = $true;
		#,[string[]]$ExtraKeywords = @()
		#,$appName = $null
		#,[switch]$NoPooling
		#,[switch]$UsePsEvents
		ConnectionTimeout = $ConnectionTimeout
		#,$FailoverPartner = $null
	}
	
	if($ExtraKeywords){
		$ConnectParams.ExtraKeywords = $ExtraKeywords;
	}
	
	if($AppName){
		$ConnectParams.appName = $AppName;
	}
	
	if($Pooling){
		write-warning "using pooled connections";
		$ConnectParams.NoPooling = $false;
	}

	$runs = 0;
	do {
		$ConnectTimes = Measure-Command {
			$Connection = Connect-SqlServer @ConnectParams
		}
		
		$ConnId = $Connection.RawConnection.ClientConnectionId;
		
		if(!$sql){
			$sql = "declare @Start datetime,@r int;select @Start = getdate();select @r = 1;select ts = getdate(),el = datediff(ms,@Start,getdate())"
		}

		$StartRequestTime = Measure-Command {
			$Request = Start-SqlRequest -connection $Connection -sql $sql;
		}

		$ReceiveTime= Measure-Command {
			$Results = Get-SqlServerNextRow -SqlRequest $Request
		}
		
		$DisconnectTime = Measure-Command {
			Disconnect-SQlServer $Connection
		}


		$o = New-Object PsObject -Prop @{
			Connect = $ConnectTimes.TotalMilliseconds
			Start	= $StartRequestTime.TotalMilliseconds
			Receive = $ReceiveTime.TotalMilliseconds
			SQLRun 	= $Results.results.el
			SQLts 	= $Results.results.ts
			Disconnect 	= $DisconnectTime.TotalMilliseconds
			Run 	= ($runs + 1)
			ClientTs = (get-date)
			Cid		= $ConnId 
		}

		write-output $o;
	
		$runs++;
		if($RepeatMs){
			Start-Sleep -m $RepeatMs;
		} else {
			break;
		}
	
	} while($runs -lt $MaxExecutions -or $MaxExecutions -eq $null)
	
	
	if($ResultVariable){
		Set-Variable -Scope 1 -Name $ResultVariable -Value $AllResult;
	}
	
}

<# 
	.SYNOPSIS	
		Get a object that represent next resultset.
		
	.DESCRIPTION
		Get next resultset from a reader create with New-SqlReaderParser
		Thiis is just a internal concepts of this module.
#>
	Function Get-SqlReaderNextResultset {
			[CmdLetBinding()]
			param(
				[parameter(ValueFromPipeline=$true)]
				$ReaderObject
				
				,#get next resultset async
					[switch]$Async
			)	
		
			
		#This is cmdlet that users must call to get next resultset!
		#The logic is:
		#	We will update the hadNext property to client know if must try get more result.
		$ResultSetObject = New-Object PsObject -Prop @{
					ReaderObject	= $ReaderObject
					ColumnNames 	= @()
					
					#This is object that represent rows returned by SqlServer.
					#We will add properties to it dynamically, based on columns returned.
					RowTemplate = New-Object PsObject;
					
					#Indicates last row was read.
					LastRowRead = $false
			}
		$ResultSetObject | Add-Member -MemberType ScriptProperty -Name reading -Value {$this.ReaderObject.reading};
		$ResultSetObject | Add-Member -MemberType ScriptProperty -Name nexting -Value {$this.ReaderObject.nexting};
		$ResultSetObject | Add-Member -MemberType ScriptProperty -Name position -Value {$this.ReaderObject.ReadCount};
		
		if($ReaderObject.nexting){
			write-verbose "Get-SqlReaderNextResultset: async next result in progres... Checking status..."
			if($ReaderObject.AsyncHandle.IsCompleted){
				write-verbose "Get-SqlReaderNextResultset: 	completed."
				$ReaderObject.nexting 	= $false;
				$ReaderObject.hadNext	= $ReaderObject.AsyncHandle.Result;
			} else {
				write-verbose "Get-SqlReaderNextResultset: 	in progress yet...";
				return;
			}
		} else {
			try {
				#Now, lets configure hadNext to points to null. This indicates that we dont know about if there are most results to fetch...
				$ReaderObject.hadNext = $null;
				
				#Everytime user call this cmdlet, it want get next set of resultsets!
				#Reader always read rows from current resultset that is point to.
				#Everytime user call this, we point to next resultset.
				#If user nevers calls, we keep pointing to first result.
				
				#When readCount >= 1, then means the first resultset already read.
				#Out hadNext property is update in same time to user want know if there more.
				if($ReaderObject.readCount -ge 1){
					if($Async){
						write-verbose "Get-SqlReaderNextResultset: starting async next resultset..."
						$ReaderObject.AsyncHandle 	= $ReaderObject.reader.NextResultAsync();
						$ReaderObject.nexting 		= $true;
						return;
					} else {
						$ReaderObject.hadNext = $ReaderObject.reader.NextResult();
					}
					
				} else {
					write-verbose "First resultset, already ready!"
					#If readCount < 1, then is the first time call. So, lets keep pointer to first resultset.
					$ReaderObject.hadNext = $true;
				}
				
			} finally {
				$ReaderObject.readCount++; #Increment our readcount, indepently if throws exceptions or not...
			}
		}
		
		if($ReaderObject.hadNext){
			return $ResultSetObject;
		} else {
			#Close reader!
			write-verbose "Get-SqlReaderNextResultset: No more resultset... closing reader...";
			$ReaderObject.reader.Dispose();
			return;
		}	
	}
	
<# 
	.SYNOPSIS	
		Get next sql rows, or all rows, from a resultset
		
	.DESCRIPTION
		Get next sql rows, or all rows, from a resultset created with Get-SqlReaderNextResultset
#>
	Function Get-SqlReaderNextRow {
			[CmdLetBinding()]
			param(
				[parameter(ValueFromPipeline=$true)]
				$Resultset
				
				,#Fetch all rows 
					[switch]$Full
					
				,#Read asynchrnously
					[switch]$Async
			)	
			
		[array]$AllRows = @();
		
		write-verbose 'Get-SqlReaderNextRow: begin consume loop...'
		
		$ReaderObject = $Resultset.ReaderObject;
		
		#Here is where we ask row by row from SqlServer.
		#This method always get from current resultset that we points to.
		#We will read up to no more rows ( result of read() will be false).
		while($true)
		{
		
			#If in async mode!
			if($ReaderObject.reading){
				write-verbose "Get-SqlReaderNextRow: Current reading in progress.. Checking if completed"
				#Check if ok...
				if($ReaderObject.AsyncHandle.IsCompleted){
					write-verbose "Get-SqlReaderNextRow: Completed!"
					$ReaderObject.reading = $false;
					$ReadResult = $ReaderObject.AsyncHandle.Result
				} else {
					write-verbose "Get-SqlReaderNextRow: In progress..."
					break; #break to follow logic (we can have some row to return form previous)
				}
			} elseif($Async){
				write-verbose "Get-SqlReaderNextRow: async read starting..."
				$ReaderObject.AsyncHandle 	= $ReaderObject.reader.readAsync()
				$ReaderObject.reading		= $true;
				write-verbose "Get-SqlReaderNextRow: 	async read started..."
				break; #break to follow logic (we can have some row to return form previous)
			} else {
				write-verbose "Get-SqlReaderNextRow: sync read started..."
				$ReadResult = $ReaderObject.reader.read()
			}
			
			#If no rows, then just ends loop.
			if(!$ReadResult){
				$Resultset.LastRowRead = $true;
				break;
			}		
				
				
			#Lets build a sample object that will contains the columns...
			#Thanks to GotColumns variable, we will do this just one time for each resultset.
			if(!$Resultset.ColumnNames){
				$i = $ReaderObject.reader.FieldCount;
				$Resultset.ColumnNames = new-object 'string[]' $i;
				
				#For each column...
				write-verbose "Get-SqlReaderNextRow: building columns list: $i columns"
				while($i--){
					$ColumnName 	= $ReaderObject.reader.GetName($i);  
					
					#If hasn't name, then generate a default...
					if(!$ColumnName){
						$ColumnName = "(No Column Name $i)"
					}
					
					$Resultset.RowTemplate | Add-Member -Name $ColumnName -Type Noteproperty -Value $null;
					$Resultset.ColumnNames[$i] = $ColumnName;
				}

				write-verbose "Get-SqlReaderNextRow: column list count: $($Resultset.ColumnNames.count) "
			}

			#Alright, at this point, we can iterate over column for get the value, for each row...
			#For each column value, in current row, lets fill the our object representing our row..
			
			#Here, we iterate over all columns of ccurrent rows to set on our row template.
			$i = $ReaderObject.reader.FieldCount;
			while($i--){
				$ColumnName = $Resultset.ColumnNames[$i]; #Get current colummn name from column name cache...;
				
				if($ReaderObject.reader.isDbNull($i)){
					$ColumnValue = $null;
				} else {
					$ColumnValue = $ReaderObject.reader.getValue($i);
				}
				
				$Resultset.RowTemplate.$ColumnName = $ColumnValue;
			}
			

			$AllRows += $Resultset.RowTemplate.psobject.copy();
			
			#If not retrieve all rows, ends loop.
			if(!$Full){
				break;
			}
		}
		
		#Returning to caller...
		return $AllRows;
	}