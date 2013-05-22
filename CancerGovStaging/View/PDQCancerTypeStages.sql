IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQCancerTypeStages]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[PDQCancerTypeStages]
GO
CREATE VIEW dbo.PDQCancerTypeStages
AS

SELECT *
FROM  CancerGov.dbo.PDQCancerTypeStages

GO
