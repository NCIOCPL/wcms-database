IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_GenericModule_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_GenericModule_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_GenericModule_Update
    @GenericModuleID uniqueidentifier
	,@Namespace varchar(256)
    ,@category  int
	,@moduleClass varchar(100)	
	,@AssemblyName varchar(100)
	,@EditNamespace varchar(256)
	,@EditmoduleClass varchar(100)
	,@EditAssemblyName varchar(100)
	,@IsVirtual bit
    ,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_GenericModuleExists(@GenericModuleID,@Namespace, @moduleClass ) =1)
			return 10200 -- Exists

		Update dbo.GenericModule
		Set Namespace= @Namespace
			,category = @category
			,moduleClass = @moduleClass
			,AssemblyName= @AssemblyName 
			,EditNamespace= @EditNamespace
			,EditModuleClass= @EditmoduleClass 
			,EditAssemblyName= @EditAssemblyName
			,IsVirtual= @IsVirtual 
		  ,[UpdateUserID]= @UpdateUserID
		  ,[UpdateDate] = getdate()
		Where   GenericModuleID = @GenericModuleID
		
	END TRY

	BEGIN CATCH
		RETURN 10104
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_GenericModule_Update] TO [websiteuser_role]
GO
