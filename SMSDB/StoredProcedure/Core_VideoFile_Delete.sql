IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoFile_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoFile_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoFile_Delete
	@FileID uniqueidentifier
	
AS
BEGIN

	BEGIN TRY

	DELETE FROM dbo.VideoFile
		WHERE	FileID = @FileID

	END TRY

	BEGIN CATCH
		RETURN 10805
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoFile_Delete] TO [websiteuser_role]
GO
