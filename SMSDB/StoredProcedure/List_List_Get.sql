IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_List_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_List_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_List_Get(
		@ListID UniqueIdentifier, 
		@isLive bit = 0,
		@ReturnLiveListItems bit = null
	)
	/**************************************************************************************************
	* Name		: dbo.List_List_Get
	* Purpose	: get list & list items details
	* Author	: SR
	* Date		: 04/14/2006
	* Returns	: n/a
	* Usage		: dbo.List_List_Get '1C844970-2ED9-40B2-AE9C-AF92F355C9AC', 0
	* Changes	: 
	**************************************************************************************************/
	AS
	BEGIN

		--NOTE: At this time we are not handling sub lists.  When that happens, we 
		--will definately need to change this.
			if @isLive =1
			BEGIN
					Select 
							l.ListID, 
							l.Description, 
							l.ShowLinkDescriptions, 
							l.ShowShortTitle, 
							l.CreateUserID, 
							l.CreateDate, 
							l.UpdateUserID, 
							l.UpdateDate,
							o.Title
						from dbo.PRODList l
						JOIN dbo.PRODobject o
						ON l.ListID = o.ObjectID
						Where 
						l.ListID = @ListID
						
					--Return List Item Details for the given the ListId
					SELECT ListItemInstanceID,
							i.ListID,
							i.ListItemID,
							i.ListItemTypeID,
							i.IsFeatured,
							i.Priority,
							i.UpdateUserID,
							i.UpdateDate,
							i.OverriddenTitle,
							i.OverriddenShortTitle,
							i.OverriddenDescription,
							i.OverriddenAnchor,
							i.OverriddenQuery as OverriddenQueryParams,
							i.FileSize,
							i.FileIcon,
							i.SupplementalText
					FROM dbo.PRODListItem i
					WHERE i.ListID = @ListID
					ORDER BY i.Priority

					--Return Details for the given the ListId Internal, External and Document tables
					--External Link
					Select 
						LinkID,
						Title,
						ShortTitle,
						Description,
						Url,
						IsExternal,
						OwnerID
					FROM ExternalLink E
					WHERE LinkID in 
					(
						SELECT ListItemID from dbo.PRODListItem
						WHERE ListID = @ListID
						AND ListItemTypeID = 2
					)

					-- Node Link
					-- If IsLive=1 then we ALWAYS return Live List Items
					SELECT
						n.NodeID,
						Title,
						ShortTitle,
						Description,
						PrettyUrl as Url
					FROM dbo.PRODNode n
					JOIN dbo.PRODPrettyUrl pu
					ON n.NodeID = pu.NodeID
					AND pu.IsPrimary = 1
					WHERE n.NodeID in 
					(
						SELECT ListItemID from dbo.PRODListItem
						WHERE ListID = @ListID
						AND ListItemTypeID = 3
					)

					--Document Link
					SELECT 
						d.DocumentID,
						[FileName],
						Title,
						ShortTitle,
						Description,
						DocumentTypeID,
						OwnerID,
						dpu.PrettyUrl			
					FROM [Document] D
					JOIN DocumentPrettyURL dpu
					ON d.DocumentID = dpu.DocumentID
					AND dpu.IsPrimary = 1
					WHERE d.DocumentID in 
					(
						SELECT ListItemID from dbo.PRODListItem
						WHERE ListID = @ListID
						AND ListItemTypeID = 1
					)

			END
			else
			BEGIN
					--Return List Details for the given the ListId
						Select 
							l.ListID, 
							l.Description, 
							l.ShowLinkDescriptions, 
							l.ShowShortTitle, 
							l.CreateUserID, 
							l.CreateDate, 
							l.UpdateUserID, 
							l.UpdateDate,
							o.Title
						From List l
						JOIN Object o
						ON l.ListID = o.ObjectID
						Where 
						l.ListID = @ListID
						
					--Return List Item Details for the given the ListId
					SELECT ListItemInstanceID,
							i.ListID,
							i.ListItemID,
							i.ListItemTypeID,
							i.IsFeatured,
							i.Priority,
							i.UpdateUserID,
							i.UpdateDate,
							i.OverriddenTitle,
							i.OverriddenShortTitle,
							i.OverriddenDescription,
							i.OverriddenAnchor,
							i.OverriddenQuery as OverriddenQueryParams,
							i.FileSize,
							i.FileIcon,
							i.SupplementalText
					FROM dbo.ListItem i
					WHERE i.ListID = @ListID
					ORDER BY i.Priority

					--Return Details for the given the ListId Internal, External and Document tables
					--External Link
					Select 
						LinkID,
						Title,
						ShortTitle,
						Description,
						Url,
						IsExternal,
						OwnerID
					FROM ExternalLink E
					WHERE LinkID in 
					(
						SELECT ListItemID FROM ListItem
						WHERE ListID = @ListID
						AND ListItemTypeID = 2
					)

					-- Node Link
					--This little if statement is pretty much for best bets
					--WayneB does not want to have to approve the lists for best bets,
					--So we always return the list from the preview tables, and if we
					--are in production we join with the prodnode and prodprettyurl tables
					IF (@ReturnLiveListItems = 1)
					BEGIN
						SELECT
							n.NodeID,
							Title,
							ShortTitle,
							Description,
							PrettyUrl as Url
						FROM PRODNode n
						JOIN PRODPrettyUrl pu
						ON n.NodeID = pu.NodeID
						AND pu.IsPrimary = 1
						WHERE n.NodeID in 
						(
							SELECT ListItemID FROM ListItem
							WHERE ListID = @ListID
							AND ListItemTypeID = 3
						)
					END
					ELSE
					BEGIN
						SELECT
							n.NodeID,
							Title,
							ShortTitle,
							Description,
							PrettyUrl as Url
						FROM Node n
						JOIN PrettyUrl pu
						ON n.NodeID = pu.NodeID
						AND pu.IsPrimary = 1
						WHERE n.NodeID in 
						(
							SELECT ListItemID FROM ListItem
							WHERE ListID = @ListID
							AND ListItemTypeID = 3
						)
					END

					--Document Link
					SELECT 
						d.DocumentID,
						[FileName],
						Title,
						ShortTitle,
						Description,
						DocumentTypeID,
						OwnerID,
						dpu.PrettyUrl			
					FROM [Document] D
					JOIN DocumentPrettyURL dpu
					ON d.DocumentID = dpu.DocumentID
					AND dpu.IsPrimary = 1
					WHERE d.DocumentID in 
					(
						SELECT ListItemID FROM ListItem
						WHERE ListID = @ListID
						AND ListItemTypeID = 1
					)
			END
	END

GO
GRANT EXECUTE ON [dbo].[List_List_Get] TO [websiteuser_role]
GO
