IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TemplateProperty]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[TemplateProperty]
GO


CREATE VIEW dbo.TemplateProperty
AS

SELECT CancerGovStaging.dbo.TemplateProperty.*
FROM  CancerGovStaging.dbo.TemplateProperty

GO
