SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if object_id('dictionaryTerm_exist') is not null
	drop procedure dbo.dictionaryTerm_exist
GO
create procedure dbo.dictionaryTerm_exist(@dictionaryTerms udt_dictionaryTerm readonly)
As
BEGIN
	set nocount on 
	select t.cdrid, t.dictionarytype, t.language, t.audience, case when d.termid is null then 0 else 1 end 
	from @dictionaryterms t left outer join dbo.dictionary d on d.termid = t.cdrid and d.Dictionary = t.dictionarytype and d.Language = t.language and d.audience = t.audience
	

END

Go

grant execute on dbo.dictionaryTerm_exist to websiteuser_role
Go
