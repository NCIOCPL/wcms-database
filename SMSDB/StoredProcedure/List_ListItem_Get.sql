IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItem_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItem_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
	CREATE  PROCEDURE  dbo.List_ListItem_Get(
		@ListItemInstanceID UniqueIdentifier
	)
	/**************************************************************************************************
	* Name		: dbo.List_ListItem_Get
	* Purpose	: get list & list items details
	* Author	: SR
	* Date		: 04/14/2006
	* Returns	: n/a
	* Usage		: dbo.List_ListItem_Get '4FCC53E8-29FC-41A9-AC81-702720B47A19'
	* Changes	: 
	**************************************************************************************************/
	AS
	BEGIN
 			
		--Return List Item Details for the given the ListItemInstanceId
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
		WHERE i.ListItemInstanceID = @ListItemInstanceID

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
		WHERE LinkID = 
		(
			SELECT ListItemID FROM ListItem
			WHERE ListItemInstanceID = @ListItemInstanceID
		)

		-- Node Link
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
		WHERE n.NodeID = 
		(
			SELECT ListItemID FROM ListItem
			WHERE ListItemInstanceID = @ListItemInstanceID
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
		WHERE d.DocumentID = 
		(
			SELECT ListItemID FROM ListItem
			WHERE ListItemInstanceID = @ListItemInstanceID
		)

		--List Link?
	END

GO
GRANT EXECUTE ON [dbo].[List_ListItem_Get] TO [websiteuser_role]
GO
