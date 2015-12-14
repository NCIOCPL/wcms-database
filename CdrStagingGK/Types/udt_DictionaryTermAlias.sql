-- User-defined type for updating the DictionaryTermAlias table.
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

IF EXISTS (SELECT * FROM sys.types WHERE name = 'udt_DictionaryTermAlias' AND is_user_defined = 1 AND is_table_type = 1)
drop type udt_DictionaryEntry
GO


-- Create the data type
CREATE TYPE dbo.udt_DictionaryTermAlias AS TABLE 
(
	TermID int,
	Name nvarchar(1000),
	NameType nvarchar(30),
	Language nvarchar(20)
)
GO

GRANT EXECUTE ON TYPE::[dbo].udt_DictionaryTermAlias TO [gatekeeper_role]
GO
