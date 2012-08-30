IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoFile_GetAllForVideo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoFile_GetAllForVideo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoFile_GetAllForVideo
	@VideoID uniqueidentifier
AS
BEGIN
	BEGIN TRY

	SELECT vfile.VideoID,
		   vfile.FileID,
		   vfile.[FileName],
		   vfile.FormatTypeID,
		   vfile.QualityID,
		   vfile.width,
		   vfile.height ,
		   vfile.CreateDate,
		   vfile.CreateUserID,
		   vfile.UpdateDate,	
		   vfile.UpdateUserID
				FROM dbo.VideoFile vfile 				
					WHERE vfile.VideoID = @VideoID
		
	END TRY

	BEGIN CATCH
		RETURN 10801
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoFile_GetAllForVideo] TO [websiteuser_role]
GO
