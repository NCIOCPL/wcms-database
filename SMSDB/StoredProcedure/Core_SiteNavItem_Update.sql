IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteNavItem_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteNavItem_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_SiteNavItem_Update
	@NodeID uniqueidentifier
	,@DisplayName varchar(50)
	,@NavCategory varchar(255)
	,@NavImg varchar(50)
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (exists (select 1 from dbo.SiteNavItem where NodeID= @NodeID ))
		BEGIN
			Update dbo.SiteNavItem
			Set DisplayName = @DisplayName
				,NavCategory = @NavCategory
				,NavImg = @NavImg
				,UpdateUserID = @UpdateUserID
				,UpdateDate = getdate()
			Where NodeID = @NodeID
		END
		ELSE
		BEGIN 
			INSERT INTO [dbo].[SiteNavItem]
           ([NavItemID]
           ,[NodeID]
           ,[DisplayName]
		   ,[NavCategory]
		   ,[NavImg]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate])
		 VALUES
			(newid(), @NodeID, @DisplayName, @NavCategory, @NavImg, @UpdateUserID, getdate(),@UpdateUserID, getdate() )
		END

	END TRY

	BEGIN CATCH
		RETURN 13004
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteNavItem_Update] TO [websiteuser_role]
GO
