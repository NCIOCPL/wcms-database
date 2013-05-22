IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentManager_Document_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[DocumentManager_Document_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].DocumentManager_Document_Delete
	@DocumentID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN

	BEGIN TRY
		Delete from dbo.DocumentPrettyURL		
		WHERE DocumentID = @DocumentID	
		
		DELETE FROM dbo.[Document] 
		WHERE DocumentID = @DocumentID	

	END TRY

	BEGIN CATCH
		
			RETURN 125005  
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[DocumentManager_Document_Delete] TO [websiteuser_role]
GO
