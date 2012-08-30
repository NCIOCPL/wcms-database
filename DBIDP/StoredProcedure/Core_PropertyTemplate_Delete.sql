IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PropertyTemplate_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PropertyTemplate_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PropertyTemplate_Delete
	@PropertyTemplateID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if ((exists (select 1 from dbo.NodeProperty Where PropertyTemplateID = @PropertyTemplateID))
			or  
			(exists (select 1 from dbo.ModuleInstanceProperty Where PropertyTemplateID = @PropertyTemplateID))
			)
			return 10706

		Delete from dbo.PropertyTemplate
		  Where PropertyTemplateID = @PropertyTemplateID
		
	END TRY

	BEGIN CATCH
		RETURN 10705
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PropertyTemplate_Delete] TO [websiteuser_role]
GO
