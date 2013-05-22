IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].DocumentManager_Document_Get
	@DocumentID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		SELECT D.[DocumentID]
				,DocumentLibraryID
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
		  FROM [dbo].[Document] D, dbo.DocumentType T, dbo.DocumentPrettyURL P
		Where D.[DocumentID] = @DocumentID 
			and T.[DocumentTypeID]= D.[DocumentTypeID]
			and P.[DocumentID] = D.[DocumentID] and P.IsPrimary=1
	END TRY

	BEGIN CATCH
		
			RETURN 125001  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_Get] TO [websiteuser_role]
GO
