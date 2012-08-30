IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_ChangeParent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_ChangeParent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_ChangeParent
	@NodeID uniqueidentifier
	,@ParentNodeID uniqueidentifier =null
	,@inheritedParentLayout	bit =1 --should be removed. Have its function.
	,@UpdateUserID varchar(50)
AS
BEGIN
	Declare @rtnValue int
		,@ParentlayoutTemplateID uniqueidentifier 
		,@ParentcontentAreaTemplateID uniqueidentifier 

	BEGIN TRY

		Update [dbo].[Node]
        set	ParentNodeID = @ParentNodeID
			,[UpdateUserID] =@UpdateUserID
           ,[UpdateDate] =getdate()
		Where [NodeID] = @NodeID
        

		--rebuld permission
		exec @rtnValue = Core_ObjectPermission_RebuildNodeRoleBinaryForNode @NodeID	
		if (@rtnValue <> 0)
			return @rtnValue

		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11113 --'Core_Node_ChangeParent'
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_ChangeParent] TO [websiteuser_role]
GO
