
IF EXISTS (SELECT * FROM sys.types WHERE name = 'udt_trialids' AND is_user_defined = 1 AND is_table_type = 1)
drop type udt_trialids
GO


-- Create the data type
CREATE TYPE dbo.udt_trialids AS TABLE 
(
	trialid nvarchar(124)
)
GO

GRANT EXECUTE ON TYPE::[dbo].udt_trialids TO [CDEuser]
GO

