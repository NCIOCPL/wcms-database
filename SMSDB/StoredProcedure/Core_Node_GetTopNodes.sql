IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_GetTopNodes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_GetTopNodes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


Create  PROCEDURE [dbo].Core_Node_GetTopNodes
AS
BEGIN

	--Get the main node data.
	select top 1 NodeID, Title, ShortTitle
	from node
	where parentnodeid is null and title like '%root%'
	

END



GO
GRANT EXECUTE ON [dbo].[Core_Node_GetTopNodes] TO [websiteuser_role]
GO
