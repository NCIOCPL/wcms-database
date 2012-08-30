IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ExternalLink_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ExternalLink_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].Core_ExternalLink_Delete
	@LinkID uniqueidentifier,
	@UpdateUserID varchar(50)
AS
BEGIN

	BEGIN TRY
		if (exists (select 1 from dbo.ListItem where ListItemID = @LinkID))
		BEGIN
			return 135000 -- Used by List Item.
		END
		
		DELETE FROM dbo.ExternalLink
		WHERE LinkID = @LinkID	

	END TRY

	BEGIN CATCH
		
			RETURN 135005  
		
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[Core_ExternalLink_Delete] TO [websiteuser_role]
GO
