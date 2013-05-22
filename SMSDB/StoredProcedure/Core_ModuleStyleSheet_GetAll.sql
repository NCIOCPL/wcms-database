IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleStyleSheet_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleStyleSheet_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleStyleSheet_GetAll
AS
BEGIN
	BEGIN TRY
	
		SELECT [StyleSheetID]
		  ,[MainClassName]
		  ,[CSS]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		from  dbo.ModuleStyleSheet
		order by 	[MainClassName]

	END TRY

	BEGIN CATCH
		RETURN 10102
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleStyleSheet_GetAll] TO [websiteuser_role]
GO
