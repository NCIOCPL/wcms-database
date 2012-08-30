IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_TemplateZone_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_TemplateZone_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_TemplateZone_GetAll
AS
BEGIN
	BEGIN TRY

	
		SELECT TemplateZoneID,
			ZoneName,
			TemplateZoneTypeID
			,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		  FROM [dbo].TemplateZone
		
	END TRY

	BEGIN CATCH
		RETURN 10602
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_TemplateZone_GetAll] TO [websiteuser_role]
GO
