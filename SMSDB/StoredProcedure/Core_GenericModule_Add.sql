IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModule_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModule_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_GenericModule_Add
    @Namespace varchar(256)
    ,@category  int
	,@moduleClass varchar(100)
	,@AssemblyName varchar(100)
	,@EditNamespace varchar(256)
	,@EditmoduleClass varchar(100)
	,@EditAssemblyName varchar(100)
	,@IsVirtual bit
    ,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_GenericModuleExists(null,@Namespace, @moduleClass ) =1)
			return 10200 -- Exists

		insert into dbo.GenericModule
		(
		   GenericModuleID
		  ,Namespace
		  ,category
		  ,moduleClass
           ,[AssemblyName]
           ,[EditAssemblyName]
           ,[EditNamespace]
           ,[EditModuleClass]
           ,[IsVirtual]
		  ,[CreateUserID]
		  ,[CreateDate]
		  ,[UpdateUserID]
		  ,[UpdateDate])
		values
		(
			newid(), 
			@Namespace,
			@category,
			@moduleClass,
			@AssemblyName,
			@EditAssemblyName,
			@EditNamespace,
			@EditmoduleClass,
			@IsVirtual,
			@CreateUserID,
			getdate(),
			@CreateUserID,
			getdate()
		)
	
	END TRY

	BEGIN CATCH
		RETURN 10103
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_GenericModule_Add] TO [websiteuser_role]
GO
