IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Navigation_NavPages_Search]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Navigation_NavPages_Search]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE  dbo.Navigation_NavPages_Search(
	@Title varchar(255),
	@Url varchar(255)
)
/**************************************************************************************************
* Name		: dbo.Navigation_NavPages_Search
* Purpose	: Searches for navigational pages for a given title and url
* Author	: SRamaiah
* Date		: Oct/02/2006
* Parameters: title, URL
* Returns	: List of Nodes(NodeId, Title, URL)
* Usage		: dbo.Navigation_NavPages_Search null, null
			: dbo.Navigation_NavPages_Search 'Division', ''
* Changes	: 
**************************************************************************************************/

AS
BEGIN
--Declaration
	Declare @Temp Table(
		NodeID uniqueidentifier
		, Title varchar(255)
		, ShortTitle varchar(50)
		, URL varchar(255)
		, ParentNodeID uniqueidentifier
		, Priority int
		);

	INSERT INTO @Temp (NodeID, Title, ShortTitle, URL, ParentNodeID, Priority)
	Select n.NodeID --as ListItemObjectID
		, n.Title
		, n.ShortTitle
		, p.PrettyURL as URL
		, n.ParentNodeID
		, n.Priority
	From Node n
	JOIN PrettyUrl p on n.NodeID = p.NodeID
	Where
--		(@Title is null or len(@Title) = 0 or (N.Title like '%' + @Title +'%' 
--			or n.ShortTitle like '%' + @Title +'%'))
--		AND (@URL is null or len(@URL) = 0 or P.PrettyURL like '%' + @URL +'%')
		 isPrimary  = 1;

	

	WITH CTE (NodeID, ParentNodeID, ShortTitle, URL, Priority, TreeLevel,Title) 
	AS
	(
		select NodeID, ParentNodeID, convert(varchar(max),ShortTitle), URL, Priority, 1 as TreeLevel,ShortTitle As Title
		from @Temp
		where ParentNodeID is null
		union ALL
		select n.NodeID, n.ParentNodeID, (CTE.ShortTitle + '/' + n.ShortTitle) as ShortTitle, n.URL, n.Priority, 1 + TreeLevel,n.ShortTitle As Title
		from @Temp n
		join CTE on n.ParentNodeID = CTE.NodeID	
	)
	select NodeID, ShortTitle, URL, Priority, TreeLevel ,Title
	from CTE
	Where
		(@Title is null or len(@Title) = 0 or (Title like '%' + @Title +'%' 
			or ShortTitle like '%' + @Title +'%'))
		 AND(@URL is null or len(@URL) = 0 or URL like '%' + @URL +'%')
		
	order by TreeLevel, Priority;

END

GO
GRANT EXECUTE ON [dbo].[Navigation_NavPages_Search] TO [websiteuser_role]
GO
