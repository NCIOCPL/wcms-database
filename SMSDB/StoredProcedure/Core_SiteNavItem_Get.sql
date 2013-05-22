IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_SiteNavItem_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_SiteNavItem_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_SiteNavItem_Get
	@NodeID uniqueidentifier
AS
BEGIN
	BEGIN TRY
		Select [NavItemID]
			   ,[NodeID]
			   ,[DisplayName]
			   ,[NavCategory]
			   ,[NavImg]
			   ,[CreateUserID]
			   ,[CreateDate]
			   ,[UpdateUserID]
			   ,[UpdateDate]
		From [dbo].[SiteNavItem]
		Where      [NodeID] = @NodeID

	END TRY

	BEGIN CATCH
		RETURN 13002
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_SiteNavItem_Get] TO [websiteuser_role]
GO
