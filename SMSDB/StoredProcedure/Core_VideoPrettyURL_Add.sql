IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoPrettyURL_Add
      @VideoID uniqueidentifier = null
	, @IsPrimary bit
    , @PrettyURL varchar(512)
	, @RealURL varchar(512)
	, @CreateUserID varchar(50)	
AS
BEGIN
	BEGIN TRY
		
			set @RealURL = '/pages/video.aspx?VideoID='+ convert(varchar(36), @VideoID)


			INSERT INTO [dbo].[VideoPrettyUrl]
			   (
					VideoPrettyURLID,
					VideoID, 															
					PrettyURL,
					RealURL,  
					IsPrimary,	
					CreateUserID,
					CreateDate,
					[UpdateUserID],
					[UpdateDate])
			Values
			(newid(),@VideoID, @PrettyURL, @RealURL, @IsPrimary, @CreateUserID, getdate(), @CreateUserID, getdate())

		return 0
	
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 10803
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_Add] TO [websiteuser_role]
GO
