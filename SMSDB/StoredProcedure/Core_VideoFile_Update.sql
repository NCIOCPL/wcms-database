IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoFile_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoFile_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoFile_Update
	 @VideoID uniqueidentifier	
	,@FileID uniqueidentifier
	,@fileName varchar(512)
	,@FormatTypeID int
	,@QualityID int
	,@Width varchar(10)
	,@Height varchar(10)
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY		

		Update dbo.[VideoFile]
		Set [FileName]= @fileName
			,FormatTypeID = @FormatTypeID
			,QualityID = @QualityID
			,Width = @Width
			,Height = @Height
			,UpdateUserID = @UpdateUserID
			,UpdateDate = getdate()
		Where FileID = @FileID
	

	END TRY

	BEGIN CATCH
		RETURN 10304
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoFile_Update] TO [websiteuser_role]
GO
