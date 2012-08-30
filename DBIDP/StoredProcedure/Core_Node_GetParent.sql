IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_GetParent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_GetParent]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


Create  PROCEDURE [dbo].[Core_Node_GetParent]
	@NodeID uniqueidentifier
AS
BEGIN

	--Get the main node data.
	select 
		ParentNodeID
	from node
	where nodeid=@NodeID

END



GO
GRANT EXECUTE ON [dbo].[Core_Node_GetParent] TO [websiteuser_role]
GO
