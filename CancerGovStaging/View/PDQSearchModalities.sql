IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQSearchModalities]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[PDQSearchModalities]
GO
CREATE VIEW dbo.PDQSearchModalities
AS

SELECT *
FROM  CancerGov.dbo.PDQSearchModalities

GO
