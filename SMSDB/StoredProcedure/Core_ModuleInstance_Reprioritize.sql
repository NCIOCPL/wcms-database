IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_Reprioritize]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_Reprioritize]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE dbo.Core_ModuleInstance_Reprioritize
	@ModuleInstanceID uniqueidentifier,
	@Priority int,
	@UpdateUserID varchar(50)
AS
BEGIN
	Declare  @rtnValue int,
			@NodeID uniqueidentifier

	
		SELECT @NodeID= Z.NodeID
		From [dbo].[ModuleInstance] M
		inner join dbo.ZoneInstance Z
		on Z.ZoneInstanceID = M.ZoneInstanceID
		Where	M.ModuleInstanceID=@ModuleInstanceID
	

	BEGIN TRY
	
		Update dbo.ModuleInstance
		Set Priority = @Priority,
			UpdateUserID= @UpdateUserID,
			UpdateDate = getdate()
		Where ModuleInstanceID = @ModuleInstanceID

		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
		if @rtnValue >0
			return @rtnValue

		RETURN 0
	END TRY

	BEGIN CATCH
		Print 	ERROR_MESSAGE()
		RETURN 11808
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_Reprioritize] TO [websiteuser_role]
GO
