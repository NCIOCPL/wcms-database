IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Function_GetNodeRoleBinary]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Core_Function_GetNodeRoleBinary]
GO

Create FUNCTION [dbo].Core_Function_GetNodeRoleBinary(
	@NodeID uniqueidentifier
)
RETURNS @Binary TABLE(
	RoleBinary varchar(255)
)
AS

BEGIN
	Declare @ParentNodeID uniqueidentifier
	--Check parent
	select @ParentNodeID = ParentNodeID from dbo.Node where NodeID= @NodeID

	INSERT INTO @Binary
	SELECT 
		Convert(varchar(36), MemberID) + 
		'_' +  
		(SELECT 
			CONVERT(varchar(20), Permission) as Permission 
			From [Role] WHERE RoleID = mnrm.RoleID)
	from dbo.MemberNodeRoleMap mnrm
	where NodeID= @NodeID

	if (@ParentNodeID is not null)
	BEGIN	
		WITH CTE(ParentNodeID)
		AS
		(
			SELECT ParentNodeID
			FROM dbo.Node
			WHERE NodeID= @NodeID
			UNION ALL 
			SELECT N.ParentNodeID 
			FROM  dbo.Node N
				JOIN CTE ON 
				NodeID = CTE.ParentNodeID 
		)
		
		INSERT INTO @Binary
		SELECT 
			Convert(varchar(36), M.MemberID) + 
			'_' +  
			(SELECT 
				CONVERT(varchar(20), Permission) as Permission 
				From [Role] WHERE RoleID = M.RoleID)
		from  dbo.MemberNodeRoleMap M
		inner join CTE
		on CTE.ParentNodeID = M.NodeID
	END

	RETURN 
END

GO
