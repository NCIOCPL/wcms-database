IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoFile_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoFile_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoFile_Add	 
	 @VideoID uniqueidentifier	
	,@fileName varchar(512)
	,@FormatTypeID int
	,@QualityID int
	,@Width varchar(10)
	,@Height varchar(10)
	,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		
			INSERT INTO [dbo].[VideoFile]
			   (
					FileID,
					VideoID, 
					[fileName],														
					FormatTypeID,
					QualityID,  
					width,
					height,
					CreateDate,					
					CreateUserID,					
					[UpdateDate],
					[UpdateUserID]
			   )					
			Values
			(newid(),@VideoID,@fileName, @FormatTypeID, @QualityID, @Width, @Height, getdate(), @CreateUserID, getdate(), @CreateUserID )

		return 0
	
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 10803
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoFile_Add] TO [websiteuser_role]
GO
