IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutTemplateZoneMap_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutTemplateZoneMap_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutTemplateZoneMap_GetAll
    @LayoutTemplateID uniqueidentifier
AS
BEGIN
	BEGIN TRY	
			Select Z.TemplateZoneID, Z.ZoneName, Z.TemplateZoneTypeID, M.LayoutTemplateID as TemplateID
			From  dbo.LayoutTemplateZoneMap M, dbo.TemplateZone Z
			where M.LayoutTemplateID = @LayoutTemplateID and Z.TemplateZoneID = M.TemplateZoneID

	END TRY

	BEGIN CATCH
		RETURN 11502
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutTemplateZoneMap_GetAll] TO [websiteuser_role]
GO
