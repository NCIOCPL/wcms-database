IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstance_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstance_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstance_Delete
	@ModuleInstanceID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int
		,@ObjectID uniqueidentifier
		,@NodeID uniqueidentifier


		SELECT @NodeID= Z.NodeID
		From [dbo].[ModuleInstance] M
		inner join dbo.ZoneInstance Z
		on Z.ZoneInstanceID = M.ZoneInstanceID
		Where	M.ModuleInstanceID=@ModuleInstanceID
	

	BEGIN TRY

		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
		if @rtnValue >0
			return @rtnValue
				
		Delete From dbo.ModuleInstanceProperty
		Where ModuleInstanceID = @ModuleInstanceID

		Delete From [dbo].[ModuleInstance]
		Where ModuleInstanceID = @ModuleInstanceID

		exec @rtnValue = Core_Object_Delete
			 @ObjectID = @ObjectID
			,@UpdateUserID= @UpdateUserID
				
		if (@rtnValue >0)
			return @rtnValue



		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11805
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstance_Delete] TO [websiteuser_role]
GO
