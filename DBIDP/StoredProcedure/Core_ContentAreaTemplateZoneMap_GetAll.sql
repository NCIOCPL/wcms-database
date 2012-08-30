IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ContentAreaTemplateZoneMap_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ContentAreaTemplateZoneMap_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_ContentAreaTemplateZoneMap_GetAll
    @ContentAreaTemplateID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		Select Z.TemplateZoneID, Z.ZoneName, Z.TemplateZoneTypeID,  M.ContentAreaTemplateID as TemplateID
		from dbo.ContentAreaTemplateZoneMap M, dbo.TemplateZone Z
		where M.ContentAreaTemplateID = @ContentAreaTemplateID 
			and M.TemplateZoneID = Z.TemplateZoneID
		order by Z.ZoneName
			
	END TRY

	BEGIN CATCH
		RETURN 11612
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ContentAreaTemplateZoneMap_GetAll] TO [websiteuser_role]
GO
