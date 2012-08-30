IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_GetAllDocumentItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_GetAllDocumentItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].DocumentManager_Document_GetAllDocumentItems
	@ListID uniqueidentifier
AS
BEGIN
	BEGIN TRY
		SELECT D.[DocumentID]
				,T.IconPath
			  ,[FileName]
			  ,Title
			  ,ShortTitle
			  ,D.[Description]
			  ,D.[DocumentTypeID]
			  ,[OwnerID]
			  ,[UpdateUserID]
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateDate]
			  ,DocumentLibraryID
		  FROM [dbo].[Document] D, dbo.DocumentType T
		Where D.[DocumentID] in 
			(
				select ListItemID From dbo.ListItem where ListID = @ListID
			)
			and T.[DocumentTypeID]= D.[DocumentTypeID]
	END TRY

	BEGIN CATCH
		
			RETURN 125008 
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_GetAllDocumentItems] TO [websiteuser_role]
GO
