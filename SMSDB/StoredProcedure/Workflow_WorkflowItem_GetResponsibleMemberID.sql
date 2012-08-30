IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_WorkflowItem_GetResponsibleMemberID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_WorkflowItem_GetResponsibleMemberID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
@Modified by Jay
@Modified on Aug. 1, 2007
@Purpose:	Modify to accomodate the change in User table and removing of RolePermisionMap table.
*/
CREATE  PROCEDURE [dbo].Workflow_WorkflowItem_GetResponsibleMemberID
	@WorkflowItemID uniqueidentifier,
	@Action int,
	@Permission int,
	@submitterName varchar(50) output
AS
BEGIN
	BEGIN TRY
		Declare @ParentNodeID uniqueidentifier
		--Check parent
		select @ParentNodeID = ParentNodeID from dbo.Node where NodeID= @WorkflowItemID

		Declare @parent table
		(
			memberID uniqueidentifier
		)

		INSERT INTO @parent
		select M.MemberID
		from dbo.MemberNodeRoleMap M, dbo.[Role] R
		where M.NodeID= @WorkflowItemID and M.RoleID= R.RoleID 
			and ((R.Permission & @Permission) > 0)
		
		if (@Action =3 or @Action =4)
		BEGIN
			select @submitterName = (select top 1 ActionBy from dbo.WorkflowItemStatusHistory
				 where WorkflowItemID = @WorkflowItemID and ([action]= 2 or [Action]=7)
				order by Date desc)
			/*INSERT INTO @parent
			select UserID from [User] where UserName= 
				(select top 1 ActionBy from dbo.WorkflowItemStatusHistory
				 where WorkflowItemID = @WorkflowItemID and ([action]= 2 or [Action]=7)
				order by Date desc)*/
		END


		if (@ParentNodeID is not null)
		BEGIN	
			WITH CTE(ParentNodeID)
			AS
			(
				SELECT ParentNodeID
				FROM dbo.Node
				WHERE NodeID= @WorkflowItemID
				UNION ALL 
				SELECT N.ParentNodeID 
				FROM  dbo.Node N
					JOIN CTE ON 
					NodeID = CTE.ParentNodeID 
			)
			
			INSERT INTO @parent
			select M.MemberID
			from dbo.MemberNodeRoleMap M, dbo.[Role] R, CTE
			where M.RoleID= R.RoleID and  ((R.Permission & @Permission) > 0)
				and CTE.ParentNodeID = M.NodeID
			
		END

		select distinct memberID from @parent

	END TRY

	BEGIN CATCH
		RETURN 126009
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Workflow_WorkflowItem_GetResponsibleMemberID] TO [websiteuser_role]
GO
