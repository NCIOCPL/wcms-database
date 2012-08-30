IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Module_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Module_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Module_Get
	@ModuleID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		--Get out ModuleInfo
		SELECT
			  [ModuleID] 
			  ,[ModuleName]
			  ,[GenericModuleID]
			  ,[CSSID]
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate]
		  FROM [dbo].[Module]
		  Where [ModuleID] = @ModuleID
		
		--Get out StyleSheet
		SELECT [StyleSheetID]
		  ,[MainClassName]
		  ,[CSS]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		FROM  dbo.ModuleStyleSheet
		WHERE StyleSheetID = (SELECT CSSID From Module WHERE ModuleID = @ModuleID)

		--Get out GenericModuleInfo
		SELECT [GenericModuleID]
		  ,[Namespace]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		  ,[category]
		  ,[moduleClass]
		  ,[EditNamespace]
		  ,[EditModuleClass]
		  ,[AssemblyName]
		  ,[IsVirtual]
		  ,[EditAssemblyName]
		FROM [dbo].[GenericModule]
		Where   GenericModuleID = (SELECT GenericModuleID From Module WHERE ModuleID = @ModuleID)
			
	END TRY

	BEGIN CATCH
		RETURN 10301
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Module_Get] TO [websiteuser_role]
GO
