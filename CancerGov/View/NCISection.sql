IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCISection]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[NCISection]
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE VIEW dbo.NCISection
AS

SELECT     
	[Description], 
	[Name], 
	NCISectionID, 
	SectionHomeViewID, 
	UpdateDate, 
	UpdateUserID, 
	URL, 
	TabImgName, 
	OrderLevel, 
	ParentSectionID, 
	SiteID
FROM         CancerGovStaging.dbo.NCISection


GO
GRANT SELECT ON [dbo].[NCISection] TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([Description]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([Description]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([Name]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([Name]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([NCISectionID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([NCISectionID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([SectionHomeViewID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([SectionHomeViewID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([UpdateDate]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([UpdateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([UpdateUserID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([UpdateUserID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([URL]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([URL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([TabImgName]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([TabImgName]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([OrderLevel]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([OrderLevel]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([ParentSectionID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([ParentSectionID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([SiteID]) TO [gatekeeper_role]
GO
GRANT SELECT ON [dbo].[NCISection] ([SiteID]) TO [websiteuser_role]
GO
