IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_VideoPrettyURL_Update
	 @VideoID uniqueidentifier
	,@VideoPrettyURLID uniqueidentifier
	,@IsPrimary bit
    ,@PrettyURL varchar(512)	
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY	
 
				Declare @RealURL varchar(512) 
				SET @RealURL = '/pages/video.aspx?VideoID='+ convert(varchar(36), @VideoID)
				
				UPDATE dbo.VideoPrettyURL
				SET					
					PrettyURL = @PrettyURL,
					RealURL = @RealURL,  
					IsPrimary = @IsPrimary,					
					[UpdateUserID] = @UpdateUserID,
					[UpdateDate] = GetDate()
				where VideoPrettyURLID = @VideoPrettyURLID			
		
	END TRY

	BEGIN CATCH
		RETURN 10304
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_Update] TO [websiteuser_role]
GO
