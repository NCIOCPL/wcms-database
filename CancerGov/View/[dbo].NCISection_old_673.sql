IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[[dbo]].NCISection_old_673]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[[dbo]].NCISection_old_673]
GO
CREATE VIEW dbo.NCISection
AS

SELECT     Description, Name, NCISectionID, SectionHomeViewID, UpdateDate, UpdateUserID, URL, TabImgName
FROM         CancerGovStaging.dbo.NCISection

GO
