IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetUserNode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetUserNode]
GO

Create FUNCTION [dbo].Core_Function_GetUserNode(
	 @UserID uniqueidentifier
)
RETURNS @Node TABLE(
	NodeID uniqueidentifier
)
AS

BEGIN	

	Declare @member table
	(
		memberID uniqueidentifier
	)

	insert into @member
	select @UserID

	insert into @member
	select GroupID
	From dbo.GroupUserMap where UserID= @UserID and groupID not in
	(select groupID from dbo.[group] where isactive=0)

	BEGIN
		WITH CTE(NodeID)
		AS
		(
			SELECT NodeID
			FROM dbo.Node
			WHERE NodeID in (
				select M.NodeID
				from dbo.MemberNodeRoleMap M , @member T 
				where M.MemberID =  T.memberID
				)
			UNION ALL 
			SELECT N.NodeID 
			FROM  dbo.Node N
				JOIN CTE ON 
				ParentNodeID = CTE.NodeID 
		)

		insert into @Node
		select distinct NodeID from CTE

	END

	return
END

GO
