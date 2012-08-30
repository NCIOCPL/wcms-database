IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Module_GetAllByCSSID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Module_GetAllByCSSID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Module_GetAllByCSSID
(
	@CSSID uniqueidentifier
)
AS
BEGIN
	BEGIN TRY

		--Get out all ModuleInfo
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
		WHERE CSSID = @CSSID
		ORDER by ModuleName
		
		--Get out all StyleSheets
		SELECT [StyleSheetID]
		  ,[MainClassName]
		  ,[CSS]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate]
		FROM  dbo.ModuleStyleSheet
		WHERE StyleSheetID = @CSSID

		--Get out all GenericModuleInfo
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
		Where GenericModuleID in (SELECT GenericModuleID From Module WHERE CSSID = @CSSID)
			
	END TRY

	BEGIN CATCH
		RETURN 10302
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Module_GetAllByCSSID] TO [websiteuser_role]
GO
