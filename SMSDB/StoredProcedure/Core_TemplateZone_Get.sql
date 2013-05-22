IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_TemplateZone_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_TemplateZone_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_TemplateZone_Get
    @TemplateZoneID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		SELECT 
			ZoneName,
			TemplateZoneTypeID
			,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		  FROM [dbo].TemplateZone
		Where   TemplateZoneID = @TemplateZoneID
		

	END TRY

	BEGIN CATCH
		RETURN 10601
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_TemplateZone_Get] TO [websiteuser_role]
GO
