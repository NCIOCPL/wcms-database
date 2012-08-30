IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Navigation_NavTree_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Navigation_NavTree_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Navigation_NavTree_Get
	@RootNodeID uniqueidentifier,
	@TreeLevelNum int,
	@isLive bit = 0
	
AS
BEGIN

		if @isLive = 1
			BEGIN
				WITH CTE (NodeID, ParentNodeID, DisplayName, NavCategory, NavImg, Title, ShortTitle, Description, ShowInNavigation, Priority, TreeLevel) 
				AS
				(
					SELECT n.NodeID, 
						ParentNodeID, 
						(SELECT DisplayName from dbo.ProdSiteNavItem WHERE nodeid=n.nodeid) as DisplayName, 
						(SELECT NavCategory from dbo.ProdSiteNavItem WHERE nodeid=n.nodeid) as NavCategory, 
						(SELECT NavImg from dbo.ProdSiteNavItem WHERE nodeid=n.nodeid) as NavImg, 
						Title, 
						ShortTitle, 
						Description, 
						ShowInNavigation, 
						Priority, 
						1 as TreeLevel
                      
					FROM dbo.PRODNode n
					WHERE n.NodeID = @RootNodeID
					UNION ALL
					SELECT n.NodeID, 
						n.ParentNodeID, 
						(SELECT DisplayName from dbo.ProdSiteNavItem WHERE nodeid=n.nodeid) as DisplayName,
						(SELECT NavCategory from dbo.ProdSiteNavItem WHERE nodeid=n.nodeid) as NavCategory, 
						(SELECT NavImg from dbo.ProdSiteNavItem WHERE nodeid=n.nodeid) as NavImg,  
						n.Title, 
						n.ShortTitle, 
						n.Description, 
						n.ShowInNavigation, 
						n.Priority, 
						1 + TreeLevel
                        
					FROM dbo.PRODNode n
					JOIN CTE
					ON n.ParentNodeID = CTE.NodeID
					where TreeLevel<=@TreeLevelNum and n.ShowInNavigation=1
				)

				SELECT 
					CTE.NodeID, 
					ParentNodeID, 
					DisplayName, 
					NavCategory, 
					NavImg, 
					Title, 
					ShortTitle, 
					Description, 					
					PrettyURL = COALESCE(
						(SELECT PropertyValue 
							FROM PRODNodeProperty 
							WHERE PropertyTemplateID in (
								SELECT PropertyTemplateID 
								FROM PropertyTemplate 
								WHERE PropertyName = 'RedirectURL'
							) 
							AND NodeID = CTE.NodeID
						)
						, PrettyURL
					), 
					ShowInNavigation, 
					Priority, 
					TreeLevel
                    
				FROM CTE
				JOIN dbo.PRODPrettyUrl pu
				ON CTE.NodeID = pu.NodeID
				AND IsPrimary = 1
				ORDER By TreeLevel, Priority
			END
		else
			BEGIN
				WITH CTE (NodeID, ParentNodeID, DisplayName, NavCategory, NavImg, Title, ShortTitle, Description, ShowInNavigation, Priority, TreeLevel) 
				AS
				(
					SELECT n.NodeID, 
						ParentNodeID, 
						(SELECT DisplayName from dbo.SiteNavItem WHERE nodeid=n.nodeid) as DisplayName,
						(SELECT NavCategory from dbo.SiteNavItem WHERE nodeid=n.nodeid) as NavCategory, 
						(SELECT NavImg from dbo.SiteNavItem WHERE nodeid=n.nodeid) as NavImg,  
						Title, 
						ShortTitle, 
						Description, 
						ShowInNavigation, 
						Priority, 
						1 as TreeLevel
                       
					FROM dbo.Node n
					WHERE NodeID = @RootNodeID
					UNION ALL
					SELECT n.NodeID, 
						n.ParentNodeID, 
						(SELECT DisplayName from dbo.SiteNavItem WHERE nodeid=n.nodeid) as DisplayName, 
						(SELECT NavCategory from dbo.SiteNavItem WHERE nodeid=n.nodeid) as NavCategory, 
						(SELECT NavImg from dbo.SiteNavItem WHERE nodeid=n.nodeid) as NavImg, 
						n.Title, 
						n.ShortTitle, 
						n.Description, 
						n.ShowInNavigation, 
						n.Priority, 
						1 + TreeLevel
                      
					FROM dbo.Node n
					JOIN CTE
					ON n.ParentNodeID = CTE.NodeID
					where TreeLevel<=@TreeLevelNum and n.ShowInNavigation=1
				)

				SELECT 
					CTE.NodeID, 
					ParentNodeID, 
					DisplayName, 
					NavCategory, 
					NavImg, 
					Title, 
					ShortTitle, 
					Description, 
					PrettyURL = COALESCE(
						(SELECT PropertyValue 
							FROM NodeProperty 
							WHERE PropertyTemplateID in (
								SELECT PropertyTemplateID 
								FROM PropertyTemplate 
								WHERE PropertyName = 'RedirectURL'
							) 
							AND NodeID = CTE.NodeID
						)
						, PrettyURL
					),
					ShowInNavigation, 
					Priority, 
					TreeLevel
                    
				FROM CTE
				JOIN PrettyUrl pu
				ON CTE.NodeID = pu.NodeID
				AND IsPrimary = 1
				ORDER By TreeLevel, Priority
			END
END

GO
GRANT EXECUTE ON [dbo].[Navigation_NavTree_Get] TO [websiteuser_role]
GO
