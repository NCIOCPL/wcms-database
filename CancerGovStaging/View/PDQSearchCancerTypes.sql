IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQSearchCancerTypes]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[PDQSearchCancerTypes]
GO
CREATE VIEW dbo.PDQSearchCancerTypes
AS

SELECT *
FROM  CancerGov.dbo.PDQSearchCancerTypes

GO
