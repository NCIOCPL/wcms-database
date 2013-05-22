IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Person]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Person]
GO
CREATE VIEW dbo.Person
AS

SELECT *
FROM  CancerGov.dbo.Person

GO
