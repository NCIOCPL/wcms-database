IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ObjectPermission_AssignRoleToMemberForObject]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ObjectPermission_AssignRoleToMemberForObject]
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


CREATE PROCEDURE [dbo].Core_ObjectPermission_AssignRoleToMemberForObject
	@MemberID	uniqueIdentifier,
	@NodeID	uniqueIdentifier,
	@RoleID bigint,
	@CreateUserID  varchar(50)
AS
BEGIN
	Declare @rtnValue int


	BEGIN TRY
		
		if (not exists (select 1 from [dbo].Member Where  MemberID = @MemberID))
				return 90130 --Member doesn't exists 

		if (not exists (select 1 from [dbo].node Where  NodeID = @NodeID))
				return 90131 --node  doesn't exists 

		if (not exists (select 1 from [dbo].[Role] Where  RoleID = @RoleID))
				return 90132 --role  doesn't exists 

		-- check whether exists
		if (exists (select 1 from [dbo].[MemberNodeRoleMap] where [RoleID]= @RoleID 
				and  [MemberID]=@MemberID and  [NodeID]= @NodeID))
			return 90133

		--Insert into map

		if (exists (select 1 from [dbo].[MemberNodeRoleMap] where 
			[MemberID]=@MemberID and  [NodeID]= @NodeID))
		BEGIN
			Update [dbo].[MemberNodeRoleMap]
			set [RoleID] = @RoleID,
				[CreateDate] = getdate(), 
				[CreateUserID] = @CreateUserID
			where [MemberID]=@MemberID and  [NodeID]= @NodeID
		END
		ELSE
		BEGIN
		
			INSERT INTO [dbo].[MemberNodeRoleMap]
			   ([RoleID]
			   ,[MemberID]
			   ,[NodeID]
				,[CreateDate],[CreateUserID])
			values
			(	@RoleID
				,@MemberID
				,@NodeID
				,getdate(),@CreateUserID)
		END

		-- rebuild dbo.NodeRoleBinary for this nodeID and children

		exec @rtnValue= dbo.Core_ObjectPermission_RebuildNodeRoleBinaryForNode
			@NodeID= @NodeID

		if @rtnValue >0
			return @rtnValue

		return 0 
		
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 90103
	END CATCH 
END



GO
GRANT EXECUTE ON [dbo].[Core_ObjectPermission_AssignRoleToMemberForObject] TO [websiteuser_role]
GO
