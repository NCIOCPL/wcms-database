IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwDrug]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwDrug]
GO

CREATE VIEW dbo.vwDrug
WITH SCHEMABINDING
AS

SELECT 	T.TermID AS DrugID,
	T.[Name],
	T.ShortName,
	T.Acronym,
	T.Definition,
	T.SourceID AS PDQSourceID
FROM 	dbo.TermType AS TT, dbo.Terminology AS T, dbo.Type AS Tp 
WHERE 	T.TermID = TT.TermID 
	AND TT.Type = Tp.TypeID
	AND Tp.SourceID = 208




GO
