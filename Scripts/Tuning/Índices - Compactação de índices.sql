/*
-- COMPACTAÇÃO DE DADOS
	- v. <2016 = Somente no Enterprise, >= v.2016 Standard 
	- Os dados ficam compactado no disco e em memória, são descompactados no momento em que são utilizados (ex. select). 
	- Ganho de performance em disco e memoria, porém aumenta o consumo de CPU
	- 2 Tipos: Page e Row
		○ Page: compacta mais e consome mais CPU, feito por strings, se tiver repetição de strings ele compacta criando um alias para elas.
		○ Row: compacta menos e consome menos CPU, feito por tipos de dados criando ponteiros
	- Há um script para verificar o ganho de compactação de cada um dos tipos.
*/		

-- COMANDO
ALTER INDEX NOME_INDEX ON NOME_TABELA REBUILD WITH(DATA_COMPRESSION=PAGE)
