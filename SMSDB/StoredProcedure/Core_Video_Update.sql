IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Video_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Video_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Video_Update
      @VideoID uniqueidentifier 
    , @Title varchar(255)
	, @ShortTitle varchar(55)
	, @Description varchar(1500)	
	, @UpdateUserID varchar(50)	
AS
BEGIN
	BEGIN TRY  

				UPDATE dbo.Video
				SET					
					Title = @Title,
					ShortTitle = @ShortTitle,  
					Description = @Description,						
					UpdateUserID = @UpdateUserID,
					UpdateDate = GetDate()	
				where VideoID = @VideoID			
			
		return 0
	
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 10803
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Video_Update] TO [websiteuser_role]
GO
