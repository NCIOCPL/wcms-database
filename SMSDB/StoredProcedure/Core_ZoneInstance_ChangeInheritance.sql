IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ZoneInstance_ChangeInheritance]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ZoneInstance_ChangeInheritance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_ZoneInstance_ChangeInheritance
	@ZoneInstanceID uniqueidentifier 
	,@UpdateUserID varchar(50)
AS
BEGIN
		Declare @rtnValue int,
				@NodeID uniqueidentifier

		select @NodeID = NodeID from dbo.ZoneInstance
		where ZoneInstanceID = @ZoneInstanceID

	BEGIN TRY

		update dbo.ZoneInstance
		set CanInherit = 1- CanInherit
		where ZoneInstanceID = @ZoneInstanceID
		
		exec @rtnValue = dbo.Core_Node_SetStatus @NodeID, @UpdateUserID
		if (@rtnValue >0)
			return @rtnValue

	END TRY

	BEGIN CATCH
		RETURN 11009
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_ZoneInstance_ChangeInheritance] TO [websiteuser_role]
GO
