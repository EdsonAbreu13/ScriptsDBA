

-- Dicas para ter cuidado em uma Atualiza��o grande do Protheus.

-- Atualiza��es pequenas pode n�o ser necess�rio.




-- 1.0) Parar o sistema (Analista Protheus) 
	-- 1.1 - Desabilitar jobs do SQL Server que possam atrapalhar a atualiza��o ( Backup, Checkdb, update statistics, Rebuild de Index e qualquer outro job pesado que tenha no ambiente).
	-- 1.2 - Rodar o Script que gera o Script de Cria��o dos �ndices Customizados. Caso a atualiza��o exclua esses �ndices, ser� s� rodar esse job que recriamos os scripts.



-- 2.0) Se o backup full rodar r�pido, executar um backup FULL.

	--2.1) Se a base for gigante e n�o quiser esperar um FULL, pode realizar um backup diferencial (tem que garantir que tem dispon�vel o �ltimo FULL)



-- 3.0) Ap�s garantir que tem todos os dados salvos, mudar o recovery da base para SIMPLE

-- Assista o m�dulo de backup do curso de tarefas do dia de um DBA para entender mais a fundo sobre o assunto

	ALTER DATABASE NOME SET RECOVERY SIMPLE


-- Isso vai reduzir o risco de uma atualiza��o gigante que recrie tabelas e colunas ou que fa�a updates ou deletes grandes, exploda o log do banco e fa�a todo o processo falhar.

/*****  Acabei de te salvar de um rollback com essa dica ai   *****/



-- 4.0) Fa�a a atualiza��o do Protheus e se quiser acompanhar de perto monitore o que est� sendo feito no banco de dados

-- F5 na whoisactive
EXEC sp_whoisactive



-- 5.0) Atualiza��o finalizada com problema?

	-- 5.1) Pode renomear a base estragada para conferir algo se isso for te ajudar.
	
	-- 5.2) Se n�o for necess�rio, restaurar os backups realizados antes da atualiza��o

	-- 5.3) Voltar os jobs do SQL Server

	-- 5.4) Voltar o sistema
	


-- 6.0) A atualiza��o foi realizada com sucesso?

	--6.1) Compress�o de Dados (se for poss�vel, Edi��o Enterprise OU SQL 2016 SP1)
			--Se tiver janela para isso, a atualiza��o pode ter desfeito a compress�o que tinha realizado na base de dados.
				--Para evitar essa mudan�a no ambiente, seria interessante compactar novamente.

	-- 6.2) Voltar o recovery da base para FULL

		ALTER DATABASE NOME SET RECOVERY FULL

	-- 6.3) Fazer um backup FULL do banco de dados

		-- Se o backup do log tentar rodar nesse momento vai falhar. Para n�o ver essas falhas teria que desabilitar e voltar ap�s concluir o backup full.
	
	-- 6.4) Voltar os jobs do SQL Server

	-- 6.5) Voltar o sistema



-- 7.0)  Atualizar Estat�sticas

	-- Caso a atualiza��o tenha alterado muitos dados, � bom atualizar as estat�sticas do ambiente.
	-- Executar o job di�rio que deve existir