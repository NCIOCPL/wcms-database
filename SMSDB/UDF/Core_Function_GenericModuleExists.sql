IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GenericModuleExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GenericModuleExists]
GO

Create FUNCTION [dbo].Core_Function_GenericModuleExists(
	@GenericModuleID uniqueidentifier = null
    ,@Namespace varchar(50)
	,@moduleClass varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.GenericModule
		where Namespace = @Namespace and  moduleClass= @moduleClass
		and (@GenericModuleID is null or GenericModuleID != @GenericModuleID)))
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
