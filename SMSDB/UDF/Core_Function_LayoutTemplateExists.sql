IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_LayoutTemplateExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_LayoutTemplateExists]
GO

Create FUNCTION [dbo].Core_Function_LayoutTemplateExists (
	@LayoutTemplateID uniqueidentifier = null
    ,@TemplateName varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.LayoutTemplate
		where TemplateName = @TemplateName 
		and (@LayoutTemplateID is null or LayoutTemplateID != @LayoutTemplateID)))
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
