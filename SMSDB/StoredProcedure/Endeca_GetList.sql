IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Endeca_GetList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Endeca_GetList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 05/02/2006
-- Description:	Get all nodes and module instances for endeca indexing
-- =============================================
CREATE PROCEDURE [dbo].[Endeca_GetList]
	@ListID uniqueidentifier ,
	@isLIve bit = 0
AS
BEGIN
	if @islIve =1
		begin
					SELECT 
						l.ListID,
						o.Title as ListTitle,
						l.Description as ListDescription,
						li.ListItemInstanceID,
						li.OverriddenTitle,
						li.OverriddenShortTitle,
						li.OverriddenDescription,
						li.ListItemID,
						li.ListItemTypeID,
						d.Title,
						d.ShortTitle,
						d.Description,
						dpu.PrettyURL as Url
					FROM ProdList l
					JOIN ProdObject o
					ON l.ListID = o.ObjectID
					JOIN ProdListItem li
					ON l.ListID = li.ListID
					AND li.ListItemTypeID = 1
					JOIN [Document] d
					ON li.ListItemID = d.DocumentID
					JOIN DocumentPrettyUrl dpu
					ON d.DocumentID = dpu.DocumentID
					WHERE l.ListID = @ListID
					UNION ALL
					SELECT 
						l.ListID,
						o.Title as ListTitle,
						l.Description as ListDescription,
						li.ListItemInstanceID,
						li.OverriddenTitle,
						li.OverriddenShortTitle,
						li.OverriddenDescription,
						li.ListItemID,
						li.ListItemTypeID,
						d.Title,
						d.ShortTitle,
						d.Description,
						d.url as Url
					FROM ProdList l
					JOIN ProdObject o
					ON l.ListID = o.ObjectID
					JOIN ProdListItem li
					ON l.ListID = li.ListID
					AND li.ListItemTypeID = 2
					JOIN [ExternalLink] d
					ON li.ListItemID = d.LinkID
					WHERE l.ListID = @ListID
					UNION ALL
					SELECT 
						l.ListID,
						o.Title as ListTitle,
						l.Description as ListDescription,
						li.ListItemInstanceID,
						li.OverriddenTitle,
						li.OverriddenShortTitle,
						li.OverriddenDescription,
						li.ListItemID,
						li.ListItemTypeID,
						d.Title,
						d.ShortTitle,
						d.Description,
						dpu.PrettyURL as Url
					FROM ProdList l
					JOIN ProdObject o
					ON l.ListID = o.ObjectID
					JOIN ProdListItem li
					ON l.ListID = li.ListID
					AND li.ListItemTypeID = 3
					JOIN ProdNode d
					ON li.ListItemID = d.NodeID
					JOIN ProdPrettyUrl dpu
					ON d.NodeID = dpu.NodeID
					WHERE l.ListID = @ListID and isPrimary  =1 --min
		end
	else
		begin
				SELECT 
						l.ListID,
						o.Title as ListTitle,
						l.Description as ListDescription,
						li.ListItemInstanceID,
						li.OverriddenTitle,
						li.OverriddenShortTitle,
						li.OverriddenDescription,
						li.ListItemID,
						li.ListItemTypeID,
						d.Title,
						d.ShortTitle,
						d.Description,
						dpu.PrettyURL as Url
					FROM List l
					JOIN Object o
					ON l.ListID = o.ObjectID
					JOIN ListItem li
					ON l.ListID = li.ListID
					AND li.ListItemTypeID = 1
					JOIN [Document] d
					ON li.ListItemID = d.DocumentID
					JOIN DocumentPrettyUrl dpu
					ON d.DocumentID = dpu.DocumentID
					WHERE l.ListID = @ListID
					UNION ALL
					SELECT 
						l.ListID,
						o.Title as ListTitle,
						l.Description as ListDescription,
						li.ListItemInstanceID,
						li.OverriddenTitle,
						li.OverriddenShortTitle,
						li.OverriddenDescription,
						li.ListItemID,
						li.ListItemTypeID,
						d.Title,
						d.ShortTitle,
						d.Description,
						d.url as Url
					FROM List l
					JOIN Object o
					ON l.ListID = o.ObjectID
					JOIN ListItem li
					ON l.ListID = li.ListID
					AND li.ListItemTypeID = 2
					JOIN [ExternalLink] d
					ON li.ListItemID = d.LinkID
					WHERE l.ListID = @ListID
					UNION ALL
					SELECT 
						l.ListID,
						o.Title as ListTitle,
						l.Description as ListDescription,
						li.ListItemInstanceID,
						li.OverriddenTitle,
						li.OverriddenShortTitle,
						li.OverriddenDescription,
						li.ListItemID,
						li.ListItemTypeID,
						d.Title,
						d.ShortTitle,
						d.Description,
						dpu.PrettyURL as Url
					FROM List l
					JOIN Object o
					ON l.ListID = o.ObjectID
					JOIN ListItem li
					ON l.ListID = li.ListID
					AND li.ListItemTypeID = 3
					JOIN Node d
					ON li.ListItemID = d.NodeID
					JOIN PrettyUrl dpu
					ON d.NodeID = dpu.NodeID
					WHERE l.ListID = @ListID and isPrimary  =1 --min
				end



END

GO
GRANT EXECUTE ON [dbo].[Endeca_GetList] TO [Endeca]
GO
