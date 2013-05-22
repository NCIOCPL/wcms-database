IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ExternalLink_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ExternalLink_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_ExternalLink_Update
	@LinkID uniqueidentifier,
	@Title varchar(255),
	@ShortTitle varchar(50),
	@Description varchar(1500),
	@URL varchar(512),
	@IsExternal bit,
	@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		
		UPDATE [dbo].[ExternalLink]
	   SET [Title] = @Title
		  ,[ShortTitle] = @ShortTitle
		  ,[Description] = @Description
		  ,[Url] = @URL
		  ,[IsExternal] = @IsExternal
		  ,[UpdateUserID] =@UpdateUserID
           ,[UpdateDate] = Getdate()
		Where [LinkID] =@LinkID

		return 0
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE()
			RETURN 135005 
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ExternalLink_Update] TO [websiteuser_role]
GO
