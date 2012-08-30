IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_TemplateZoneExists]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_TemplateZoneExists]
GO

Create FUNCTION [dbo].Core_Function_TemplateZoneExists (
	@TemplateZoneID uniqueidentifier = null
    ,@ZoneName varchar(50)
)
RETURNS bit
AS

BEGIN
	Declare @returnvalue bit
	
	if (exists (select 1 from dbo.TemplateZone 
		where ZoneName = @ZoneName 
		and (@TemplateZoneID is null or TemplateZoneID != @TemplateZoneID)))
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
