IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_RemoveRoleFromMemberForObject]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_RemoveRoleFromMemberForObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	This will get all roles mapping for a CMSGroup in the system
* Author:	Jhe
* Date:		8/21/2007
* Params:   @memberID member ID to be checked
*	
********************************************************/



CREATE PROCEDURE [dbo].Core_ObjectPermission_RemoveRoleFromMemberForObject
	@MemberID	uniqueIdentifier,
	@NodeID	uniqueIdentifier,
	@RoleID int,
	@CreateUserID  varchar(50)
AS
BEGIN	
	Declare @rtnValue int 

	BEGIN TRY


		-- check whether exists
		if (not exists (select 1 from [dbo].[MemberNodeRoleMap] where [RoleID]= @RoleID 
				and  [MemberID]=@MemberID and  [NodeID]= @NodeID))
			return 90140

		Delete From [dbo].[MemberNodeRoleMap]
        where [RoleID] = @RoleID
            and [MemberID] = @MemberID
            and [NodeID] = @NodeID

		
		exec @rtnValue= dbo.Core_ObjectPermission_RebuildNodeRoleBinaryForNode
			@NodeID= @NodeID

		if @rtnValue >0
			return @rtnValue

		return 0 
		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 90104
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_RemoveRoleFromMemberForObject] TO [websiteuser_role]
GO
