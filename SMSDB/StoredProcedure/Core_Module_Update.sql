IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Module_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Module_Update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Module_Update
	@ModuleID uniqueidentifier
	,@ModuleName varchar(50)
	,@GenericModuleID uniqueidentifier
	,@CSSID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_ModuleExists(@ModuleID, @ModuleName) =1)
			return 10300

		Update [dbo].[Module]
		Set ModuleName = @ModuleName
			,GenericModuleID = @GenericModuleID
			,CSSID = @CSSID
			,UpdateUserID = @UpdateUserID
			,UpdateDate = getdate()
		Where [ModuleID] = @ModuleID
		
	END TRY

	BEGIN CATCH
		RETURN 10304
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Module_Update] TO [websiteuser_role]
GO
