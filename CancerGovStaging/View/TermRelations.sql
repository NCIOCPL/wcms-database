IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermRelations]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[TermRelations]
GO
CREATE VIEW dbo.TermRelations
AS

SELECT TermID, RelatedTermID, RelationType, ProductID, UpdateDate, UpdateUserID
FROM  CancerGov..TermRelations


GO
