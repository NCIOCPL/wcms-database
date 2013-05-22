IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ModuleInstanceProperty_Delete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ModuleInstanceProperty_Delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ModuleInstanceProperty_Delete
	@InstancePropertyID uniqueidentifier
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int
	,@NodeID uniqueidentifier

	SELECT @NodeID= Z.NodeID
	From [dbo].[ModuleInstance] M
	inner join dbo.ModuleInstanceProperty P
	on M.ModuleInstanceID = P.ModuleInstanceID  
	inner join dbo.ZoneInstance Z
	on Z.ZoneInstanceID = M.ZoneInstanceID
	Where	P.InstancePropertyID = @InstancePropertyID

	BEGIN TRY

		Delete from dbo.ModuleInstanceProperty
		  Where InstancePropertyID = @InstancePropertyID
				
		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
		if @rtnValue >0
			return @rtnValue

		return 0
	END TRY

	BEGIN CATCH
		RETURN 11005
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ModuleInstanceProperty_Delete] TO [websiteuser_role]
GO
