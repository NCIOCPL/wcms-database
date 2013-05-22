IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_TemplateZone_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_TemplateZone_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_TemplateZone_Update
    @TemplateZoneID uniqueidentifier
	,@ZoneName varchar(50)
    ,@TemplateZoneTypeID int
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_TemplateZoneExists(@TemplateZoneID,@ZoneName) =1)
			return 10600 -- Exists

		Update dbo.TemplateZone 
		Set ZoneName= @ZoneName
			,TemplateZoneTypeID = @TemplateZoneTypeID
		  ,[UpdateUserID]= @UpdateUserID
		  ,[UpdateDate] = getdate()
		Where   TemplateZoneID = @TemplateZoneID
		
	END TRY

	BEGIN CATCH
		RETURN 10604
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_TemplateZone_Update] TO [websiteuser_role]
GO
