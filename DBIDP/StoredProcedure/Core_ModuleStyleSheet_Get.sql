IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleStyleSheet_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleStyleSheet_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleStyleSheet_Get
	@StyleSheetID uniqueidentifier
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
		Where StyleSheetID =  @StyleSheetID

		SELECT GenericModuleID
		from  dbo.GenericModuleStyleSheetMap
		Where StyleSheetID =  @StyleSheetID
	

	END TRY

	BEGIN CATCH
		RETURN 10101
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleStyleSheet_Get] TO [websiteuser_role]
GO
