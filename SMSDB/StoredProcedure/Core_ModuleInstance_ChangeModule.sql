IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_ChangeModule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_ChangeModule]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_ChangeModule
	@ModuleInstanceID uniqueidentifier
	,@ModuleID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int
			,@OriginalModuleID uniqueidentifier
			,@NodeID uniqueidentifier

	Select @OriginalModuleID = ModuleID , @NodeID = ObjectID
	from [dbo].[ModuleInstance] 
	Where ModuleInstanceID = @ModuleInstanceID

	BEGIN TRY
		Update [dbo].[ModuleInstance]
		Set ModuleID = @ModuleID
		Where ModuleInstanceID = @ModuleInstanceID

		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
		if @rtnValue >0
			return @rtnValue

		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11807
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_ChangeModule] TO [websiteuser_role]
GO
