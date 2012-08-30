IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModule_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModule_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_GenericModule_Get
    @GenericModuleID uniqueidentifier
AS
BEGIN
	BEGIN TRY

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
		Where   GenericModuleID = @GenericModuleID
		
	END TRY

	BEGIN CATCH
		RETURN 10201
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_GenericModule_Get] TO [websiteuser_role]
GO
