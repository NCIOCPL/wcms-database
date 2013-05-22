IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_ModuleExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_ModuleExists]
GO


Create FUNCTION [dbo].Core_Function_ModuleExists(
	@ModuleID uniqueidentifier = null
    ,@ModuleName varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.Module
		where ModuleName = @ModuleName 
		and (@ModuleID is null or ModuleID != @ModuleID)))
	BEGIN
		select @returnvalue = 1
	END
	else
	BEGIN
		select @returnvalue = 0
	END

	RETURN @returnvalue
END

GO
