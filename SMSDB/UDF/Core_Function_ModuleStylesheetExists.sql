IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_ModuleStylesheetExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_ModuleStylesheetExists]
GO

Create FUNCTION [dbo].Core_Function_ModuleStylesheetExists (
	@StyleSheetID uniqueidentifier = null
    ,@MainClassName varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.ModuleStyleSheet 
		where MainClassName = @MainClassName 
		and (@StyleSheetID is null or StyleSheetID != @StyleSheetID)))
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
