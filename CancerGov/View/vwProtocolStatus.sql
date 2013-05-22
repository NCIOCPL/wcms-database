IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwProtocolStatus]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwProtocolStatus]
GO

CREATE VIEW dbo.vwProtocolStatus
WITH SCHEMABINDING
AS

SELECT StatusID, 
	SourceID AS PDQStatusID, 
	Name, 
	ShortName
FROM  	dbo.Status
WHERE (SourceID IN (1, 2, 3, 4, 5, 86, 88, 200)) AND (DataSource = 'PDQ')




GO
