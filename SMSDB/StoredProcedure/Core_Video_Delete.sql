IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Video_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Video_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Video_Delete
	@VideoID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int
		
	
	BEGIN TRY	

		Delete from dbo.VideoPrettyURL
		  Where VideoID = @VideoID

		Delete from dbo.VideoFile
		  Where VideoID = @VideoID

		Delete from dbo.Video
		  Where VideoID = @VideoID
		
		--RETURN 10090
	END TRY

	BEGIN CATCH
		RETURN 10805
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Video_Delete] TO [websiteuser_role]
GO
