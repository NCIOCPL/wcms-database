IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwTermDrugDictionary]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwTermDrugDictionary]
GO

/****** Object:  View dbo.vwTermDrugDictionary    Script Date: 7/5/2006 2:15:46 PM ******/
CREATE VIEW dbo.vwTermDrugDictionary
with schemabinding
AS 

SELECT t.TermID, 
	t.PreferredName, 
	td.DefinitionHTML,
	dis.PrettyURL
FROM dbo.Terminology t
  INNER JOIN dbo.TermDefinition td ON t.TermID = td.TermID
  INNER JOIN dbo.TermSemanticType tst ON t.TermID = tst.TermID
  left outer JOIN dbo.druginfosummary dis ON t.TermID = dis.TerminologyLink
WHERE td.DefinitionType = 'Health professional'
	AND ISNULL(td.DefinitionHTML, '') <> ''
	AND tst.SemanticTypeName = 'Drug/agent'

GO
