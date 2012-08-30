IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].DocumentManager_Document_GetAll
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
			  ,D.[UpdateUserID]
			  ,D.[CreateUserID]
			  ,D.[CreateDate]
			  ,D.[UpdateDate]
			  ,P.PrettyURL
			  ,DocumentLibraryID
		  FROM [dbo].[Document] D, dbo.DocumentType T, dbo.DocumentPrettyURL P
		Where  T.[DocumentTypeID]= D.[DocumentTypeID]
				and D.DocumentID = P.DocumentID and P.IsPrimary=1
		Order by Title
		
	END TRY

	BEGIN CATCH
		
			RETURN 125002  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_GetAll] TO [websiteuser_role]
GO
