-- User-defined type for passing a list of  dictionary alias types
--
-- A) The type must be defined before any procedures can use it.
-- B) The type also needs to be granted execute permissions for
--    the role where it will be executed.
-- C) Grants for types have a slightly different syntax in that
--    they need to specify TYPE:: as part of the name.
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT * FROM sys.types WHERE name = 'udt_DictionaryAliasTypeFilter' AND is_user_defined = 1 AND is_table_type = 1)
drop type udt_DictionaryAliasTypeFilter
GO


-- Create the data type
CREATE TYPE dbo.udt_DictionaryAliasTypeFilter AS TABLE 
(
	NameType nvarchar(30)
)
GO

GRANT EXECUTE ON TYPE::[dbo].udt_DictionaryAliasTypeFilter TO [webSiteUser_role]
GO
