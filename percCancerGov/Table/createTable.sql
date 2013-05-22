------------

if object_id('autoSuggest_English') is not NULL
drop table dbo.autoSuggest_English
go
create table dbo.autoSuggest_English
( 
c int identity(1,1)
,termname varchar(890)
, weight int
, category tinyint
, termword varchar(890)
, CONSTRAINT [PK_autoSuggest_English] PRIMARY KEY CLUSTERED 
(	c
))
GO
create index NC_autosuggest_english on autosuggest_english (termword)  
create index NC_autosuggest_english_1 on autosuggest_english (termname)  
GO
--1 : bestbet
--2 : cancer term
--3:  pub locator


if object_id('autoSuggest_spanish') is not NULL
drop table dbo.autoSuggest_spanish
go
create table dbo.autoSuggest_spanish
( 
c int identity(1,1)
,termname varchar(890) collate modern_spanish_CI_AI
, weight int
, category tinyint
, termword varchar(890) collate modern_spanish_CI_AI
, CONSTRAINT [PK_autoSuggest_spanish] PRIMARY KEY CLUSTERED 
(	c
))

GO

create index NC_autosuggest_spanish on autosuggest_spanish (termword)  
create index NC_autosuggest_spanish_1 on autosuggest_spanish (termname)  
GO
-----------------------

if object_id('autosuggest_en_exclude') is not null
drop table autosuggest_en_exclude
go
create table dbo.autoSuggest_en_exclude
(termname varchar(890) 
 , CONSTRAINT [PK_autoSuggest_en_exclude] PRIMARY KEY CLUSTERED 
(
	[termname] ASC
))
GO


if object_id('autosuggest_es_exclude') is not null
drop table autosuggest_es_exclude
go
create table dbo.autoSuggest_es_exclude
(termname varchar(890) collate modern_spanish_CI_AI 
 , CONSTRAINT [PK_autoSuggest_es_exclude] PRIMARY KEY CLUSTERED 
(
	[termname] ASC
))
GO


if object_id('autosuggest_en_misspell') is not NULL
drop table autosuggest_en_misspell
go
create table dbo.autosuggest_en_misspell
(termname  varchar(890)
 ,misspell varchar(890)
  , CONSTRAINT [PK_autoSuggest_en_misspell] PRIMARY KEY CLUSTERED 
(
	[misspell] ASC
))
GO

if object_id('autosuggest_es_misspell') is not NULL
drop table autosuggest_es_misspell
go
create table dbo.autosuggest_es_misspell
(termname  varchar(890) collate modern_spanish_CI_AI 
 ,misspell varchar(890) collate modern_spanish_CI_AI 
  , CONSTRAINT [PK_autoSuggest_es_misspell] PRIMARY KEY CLUSTERED 
(
	[misspell] ASC
))
GO
 

 


