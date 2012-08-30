IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_ContentAreaTemplateExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_ContentAreaTemplateExists]
GO

Create FUNCTION [dbo].Core_Function_ContentAreaTemplateExists (
	@ContentAreaTemplateID uniqueidentifier = null
    ,@TemplateName varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.ContentAreaTemplate
		where TemplateName = @TemplateName 
		and (@ContentAreaTemplateID is null or ContentAreaTemplateID != @ContentAreaTemplateID)))
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
