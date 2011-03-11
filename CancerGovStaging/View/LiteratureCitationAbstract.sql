IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LiteratureCitationAbstract]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[LiteratureCitationAbstract]
GO

CREATE VIEW dbo.LiteratureCitationAbstract
AS

SELECT LiteratureCitationID, Abstract, UpdateDate, UpdateUserID
FROM  CancerGov.dbo.LiteratureCitationAbstract


GO
