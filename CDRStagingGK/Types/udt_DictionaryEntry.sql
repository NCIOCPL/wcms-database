-- User-defined type for updating the Dictionary table.
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

IF EXISTS (SELECT * FROM sys.types WHERE name = 'udt_DictionaryEntry' AND is_user_defined = 1 AND is_table_type = 1)
drop type udt_DictionaryEntry
GO


-- Create the data type
CREATE TYPE dbo.udt_DictionaryEntry AS TABLE 
(
	TermID int,
	TermName nvarchar(1000),
	Dictionary nvarchar(10),
	Language nvarchar(20),
	Audience nvarchar(25),
	ApiVers nvarchar(10),
	Object nvarchar(max)
)
GO

GRANT EXECUTE ON TYPE::[dbo].udt_DictionaryEntry TO [gatekeeper_role]
GO
