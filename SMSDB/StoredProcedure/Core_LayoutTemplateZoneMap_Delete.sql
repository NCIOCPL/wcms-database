IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplateZoneMap_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplateZoneMap_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplateZoneMap_Delete
    @LayoutTemplateID uniqueidentifier
    ,@TemplateZoneID uniqueidentifier
    ,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY			
		Delete from dbo.LayoutTemplateZoneMap where 
			LayoutTemplateID = @LayoutTemplateID and TemplateZoneID = @TemplateZoneID

		if (not exists (select 1 from dbo.LayoutTemplateZoneMap where TemplateZoneID = @TemplateZoneID)
					and not exists(select 1 from dbo.ContentAreaTemplateZoneMap where TemplateZoneID = @TemplateZoneID)
					and not exists(select 1 from dbo.ZoneInstance where TemplateZoneID = @TemplateZoneID))
		BEGIN
			Delete From dbo.TemplateZone where 
			TemplateZoneID = @TemplateZoneID
			
		END

		return 0

	END TRY

	BEGIN CATCH
		RETURN 11504
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplateZoneMap_Delete] TO [websiteuser_role]
GO
