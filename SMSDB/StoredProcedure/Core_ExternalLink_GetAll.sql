IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ExternalLink_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ExternalLink_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].Core_ExternalLink_GetAll
AS
BEGIN
	BEGIN TRY

	
		SELECT [LinkID]
		  ,[Title]
		  ,[ShortTitle]
		  ,[Description]
		  ,[Url]
		  ,[IsExternal]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		  ,[OwnerID]
	  FROM [dbo].[ExternalLink]
		Order by Title
		
	END TRY

	BEGIN CATCH
		
			RETURN 135002  
		
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ExternalLink_GetAll] TO [websiteuser_role]
GO
