IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ExternalLink_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ExternalLink_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].Core_ExternalLink_Add
	@Title varchar(255),
	@ShortTitle varchar(50),
	@Description varchar(1500),
	@Url varchar(512),
	@IsExternal bit,
	@OwnerID  uniqueidentifier,
	@UpdateUserID varchar(50),
	@LinkID uniqueidentifier OUTPUT
AS
BEGIN
	BEGIN TRY
		
		SET @LinkID = newID()

		INSERT INTO [dbo].[ExternalLink]
           ([LinkID]
           ,[Title]
		   ,[ShortTitle]
           ,[Description]
           ,[Url]
		   ,[IsExternal]
           ,[OwnerID]
           ,[UpdateUserID]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateDate])
     VALUES
		(@LinkID, @Title, @ShortTitle, @Description, @Url, @IsExternal, @OwnerID, 
		@UpdateUserID, @UpdateUserID, Getdate(), Getdate() )

		return 0
	END TRY

	BEGIN CATCH
		
			RETURN 135003 
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ExternalLink_Add] TO [websiteuser_role]
GO
