IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectType_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectType_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ObjectType_GetAll
AS
BEGIN
	BEGIN TRY

		SELECT [ObjectTypeID]
		  ,[Name]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		FROM [dbo].[ObjectType]
		order by [Name]
			
	END TRY

	BEGIN CATCH
		RETURN 12202
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ObjectType_GetAll] TO [websiteuser_role]
GO
