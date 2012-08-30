IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_PropertyTemplateExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_PropertyTemplateExists]
GO


Create FUNCTION [dbo].Core_Function_PropertyTemplateExists(
	@PropertyTemplateID uniqueidentifier = null
    ,@PropertyName varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.PropertyTemplate
		where PropertyName = @PropertyName 
		and (@PropertyTemplateID is null or PropertyTemplateID != @PropertyTemplateID)))
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
