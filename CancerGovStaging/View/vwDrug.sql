IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwDrug]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwDrug]
GO

CREATE VIEW dbo.vwDrug
AS

SELECT 	*
FROM 	CancerGov..vwDrug


GO
