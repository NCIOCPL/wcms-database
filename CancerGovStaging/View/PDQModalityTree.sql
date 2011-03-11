IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQModalityTree]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[PDQModalityTree]
GO
CREATE VIEW dbo.PDQModalityTree
AS

SELECT *
FROM  CancerGov.dbo.PDQModalityTree

GO
