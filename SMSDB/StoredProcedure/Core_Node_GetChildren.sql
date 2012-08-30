IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_GetChildren]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_GetChildren]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


Create  PROCEDURE [dbo].Core_Node_GetChildren
	@NodeID uniqueidentifier = null
AS
BEGIN

	--Get the main node data.
	if (@NodeID is null)
	BEGIN
		select nodeid, title, shorttitle, priority
		from node
		where ParentNodeID is null
		order by priority
	END
	ELSE
	BEGIN
		select nodeid, title, shorttitle, priority
		from node
		where ParentNodeID=@NodeID
		order by priority
	END

END



GO
GRANT EXECUTE ON [dbo].[Core_Node_GetChildren] TO [websiteuser_role]
GO
