IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_DocumentType_GetType]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_DocumentType_GetType]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].DocumentManager_DocumentType_GetType
	@Extension varchar(50)
AS
BEGIN

	BEGIN TRY
		
		select 	DocumentTypeID 
		From dbo.DocumentType
		Where Extension = @Extension

	END TRY

	BEGIN CATCH
		
			RETURN 126002  
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[DocumentManager_DocumentType_GetType] TO [websiteuser_role]
GO
