IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_ListItem_Link_Search]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_ListItem_Link_Search]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  dbo.List_ListItem_Link_Search(
	@ListID uniqueidentifier,
	@Title varchar(255),
	@Url varchar(255),
	@ListItemTypeID int
)
/**************************************************************************************************
* Name		: [dbo.List_ListItem_Link_Search]
* Purpose	: [returns links from node table]
* Author	: [SR]
* Date		: [04/27/2006]
* Parameters: [ListID]
* Returns	: [0 or errocode]
* Usage		: [dbo.List_ListItem_Link_Search '563A612D-BF11-4EF4-9ED8-76F0A8FDBC4B']
* Changes	: []
**************************************************************************************************/
AS
BEGIN

	IF (@ListItemTypeID = 3)
	BEGIN
		Select 
			n.NodeID as ListItemObjectID
			, n.Title
			, n.Description
			, p.PrettyURL as URL
		From Node n
		JOIN PrettyUrl p
		ON n.NodeID = p.NodeID
		Where
			n.NodeID Not In (Select ListItemID From dbo.ListItem Where ListID = @ListID)
			AND (@Title is null or len(@Title) =0 or (N.Title like '%' + @Title +'%' OR n.ShortTitle like '%' + @Title +'%'))
			AND (@URL is null or len(@URL) =0 or P.PrettyURL like '%' + @URL +'%')
			and isPrimary  =1 --min
	END
	ELSE IF (@ListItemTypeID = 2)
	BEGIN
		Select 
			n.LinkID as ListItemObjectID
			, n.Title
			, n.Description
			, n.URL
		From ExternalLink n
		Where
			n.LinkID Not In (Select ListItemID From dbo.ListItem Where ListID = @ListID)
			AND (@Title is null or len(@Title) =0 or (N.Title like '%' + @Title +'%' OR n.ShortTitle like '%' + @Title +'%'))
			AND (@URL is null or len(@URL) =0 or N.URL like '%' + @URL +'%')
	END
	ELSE IF (@ListItemTypeID = 1)
	BEGIN
		Select 
			n.DocumentID as ListItemObjectID
			, n.Title
			, n.Description
			, p.PrettyURL as URL
		From Document n
		JOIN DocumentPrettyUrl p
		ON n.DocumentID = p.DocumentID
		Where
			n.DocumentID Not In (Select ListItemID From dbo.ListItem Where ListID = @ListID)
			AND (@Title is null or len(@Title) =0 or (N.Title like '%' + @Title +'%' OR n.ShortTitle like '%' + @Title +'%'))
			AND (@URL is null or len(@URL) =0 or P.PrettyURL like '%' + @URL +'%')
	END
	ELSE
	BEGIN
		SELECT
			null as ListItemObjectID,
			null as Title,
			null as Description,
			null as URL
		WHERE 1=2
	END
END

GO
GRANT EXECUTE ON [dbo].[List_ListItem_Link_Search] TO [websiteuser_role]
GO
