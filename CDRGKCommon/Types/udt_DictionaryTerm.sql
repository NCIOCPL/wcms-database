SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sys.types WHERE name = 'udt_Dictionaryterm' AND is_user_defined = 1 AND is_table_type = 1)
drop type udt_DictionaryTerm
GO


-- Create the data type
CREATE TYPE dbo.udt_DictionaryTerm AS TABLE 
(
	cdrid int, dictionaryType varchar(20), language varchar(40), audience varchar(50)
)
GO

GRANT EXECUTE ON TYPE::[dbo].udt_DictionaryTerm TO [webSiteUser_role]
GO
