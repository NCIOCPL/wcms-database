IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Video_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Video_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Video_Add
      @VideoID uniqueidentifier 
    , @Title varchar(255)
	, @ShortTitle varchar(55)
	, @Description varchar(1500)
	, @PrettyURL varchar(512)
	, @CreateUserID varchar(50)	
	, @ReturnValue uniqueidentifier OUTPUT 
AS
BEGIN
	BEGIN TRY
	  Declare @RealURL varchar(512) 
	
    	select @VideoID

		if (@VideoID is NULL)
		BEGIN
		SET @VideoID = newid()
		SET @RealURL = '/pages/video.aspx?VideoID='+ convert(varchar(36), @VideoID)
		set @ReturnValue = @VideoID

				INSERT INTO dbo.Video
				(
					VideoID, 															
					Title,
					ShortTitle,  
					Description,	
					CreateUserID,
					CreateDate,
					UpdateUserID,
					UpdateDate
				)
				VALUES
				(
					@VideoID,
					@Title,
					@ShortTitle,  
					@Description,	
					@CreateUserID,
					GetDate(),
					@CreateUserID,
					GetDate()
				)

				INSERT INTO dbo.VideoPrettyURL
				(
					VideoPrettyURLID,
					VideoID, 															
					PrettyURL,
					RealURL,  
					IsPrimary,	
					CreateUserID,
					CreateDate,
					[UpdateUserID],
					[UpdateDate]
				)
				VALUES
				(
					newid(),
					@VideoID,
					@PrettyURL,
					@RealURL,
					1,
					@CreateUserID,
					GetDate(),
					@CreateUserID,
					GetDate()
				)
				
		END
		ELSE		
		BEGIN
		
			SET @RealURL = '/pages/video.aspx?VideoID='+ convert(varchar(36), @VideoID)
			set @ReturnValue = @VideoID
			INSERT INTO dbo.Video
				(
					VideoID, 															
					Title,
					ShortTitle,  
					Description,	
					CreateUserID,
					CreateDate,
					UpdateUserID,
					UpdateDate
				)
				VALUES
				(
					@VideoID,
					@Title,
					@ShortTitle,  
					@Description,	
					@CreateUserID,
					GetDate(),
					@CreateUserID,
					GetDate()
				)

			INSERT INTO dbo.VideoPrettyURL
				(
					VideoID, 															
					PrettyURL,
					RealURL,  
					IsPrimary,	
					CreateUserID,
					CreateDate,
					[UpdateUserID],
					[UpdateDate]
				)
				VALUES
				(
					@VideoID,
					@PrettyURL,
					@RealURL,
					1,
					@CreateUserID,
					GetDate(),
					@CreateUserID,
					GetDate()
				)
		return 0
		END
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 10803
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Video_Add] TO [websiteuser_role]
GO
