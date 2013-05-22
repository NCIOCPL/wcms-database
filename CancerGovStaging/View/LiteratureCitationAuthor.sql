IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LiteratureCitationAuthor]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[LiteratureCitationAuthor]
GO

CREATE VIEW dbo.LiteratureCitationAuthor
AS

SELECT LiteratureCitationID, AuthorType, AuthorID, SequenceNumber, UpdateDate, UpdateUserID
FROM  CancerGov.dbo.LiteratureCitationAuthor


GO
