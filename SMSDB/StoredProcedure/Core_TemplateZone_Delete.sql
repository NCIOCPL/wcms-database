IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_TemplateZone_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_TemplateZone_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_TemplateZone_Delete
	@TemplateZoneID uniqueidentifier
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from dbo.ContentAreaTemplateZoneMap
				where TemplateZoneID = @TemplateZoneID) or 
			exists (select 1 from dbo.LayoutTemplateZoneMap
				where TemplateZoneID = @TemplateZoneID) or 
			exists ( select 1 from dbo.ZoneInstance
				where TemplateZoneID = @TemplateZoneID))
			return 10606		

		Delete from dbo.LayoutTemplateZoneMap
		Where TemplateZoneID = @TemplateZoneID

		Delete from dbo.LayoutTemplateZoneMap
		Where TemplateZoneID = @TemplateZoneID

		Delete from dbo.TemplateZone
		Where TemplateZoneID = @TemplateZoneID
	
	END TRY

	BEGIN CATCH
		RETURN 10205 -- Delete
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_TemplateZone_Delete] TO [websiteuser_role]
GO
