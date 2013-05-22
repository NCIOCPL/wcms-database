IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SiteProperties]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[SiteProperties]
GO

CREATE VIEW dbo.SiteProperties
AS

SELECT PropertyName, PropertyValue, UpdateDate, UpdateUserID
FROM  CancerGovStaging.dbo.SiteProperties


GO
GRANT SELECT ON [dbo].[SiteProperties] TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[SiteProperties] ([PropertyName]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[SiteProperties] ([PropertyValue]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[SiteProperties] ([UpdateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[SiteProperties] ([UpdateUserID]) TO [websiteuser_role]
GO
