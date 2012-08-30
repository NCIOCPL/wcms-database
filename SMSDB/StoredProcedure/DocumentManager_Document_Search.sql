IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_Search]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_Search]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].DocumentManager_Document_Search
	@ListID uniqueidentifier,
	@Name varchar(255) = null,
	@Description  varchar(1500) = null,
	@DocumentTypeID int = null
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
		Where  T.[DocumentTypeID]= D.[DocumentTypeID]
			and P.[DocumentID] = D.[DocumentID] and P.IsPrimary=1
			and D.DocumentID not in (select listitemID from dbo.ListItem where listID= @ListID)
			and (D.Title is null or D.Title like '%' + @Name +'%')
			and (D.[Description] is null or D.[Description] like '%' + @Description +'%')
			and (D.DocumentTypeID is null or D.DocumentTypeID = @DocumentTypeID)
		Order by Title

	END TRY

	BEGIN CATCH
		
			RETURN 125009  
		
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_Search] TO [websiteuser_role]
GO
