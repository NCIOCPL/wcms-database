IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Module_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Module_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Module_Add
	@ModuleName varchar(50)
	,@GenericModuleID uniqueidentifier
	,@CSSID uniqueidentifier
	,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_ModuleExists(null, @ModuleName) =1)
			return 10300

		Insert into [dbo].[Module]
		(ModuleID, ModuleName ,GenericModuleID, CSSID, CreateUserID, CreateDate, UpdateUserID,UpdateDate )
		values
		(newid(), @ModuleName, @GenericModuleID, @CSSID, @CreateUserID, getdate(), @CreateUserID, getdate())
		
	END TRY

	BEGIN CATCH
		RETURN 10303
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Module_Add] TO [websiteuser_role]
GO
