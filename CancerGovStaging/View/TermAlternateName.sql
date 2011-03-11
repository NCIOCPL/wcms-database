IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermAlternateName]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[TermAlternateName]
GO

CREATE VIEW TermAlternateName
AS
	
SELECT 	[TermID],
		[Type],
		[Name],
		[UpdateDate],
		[UpdateUserID]
	FROM 	CancerGov..TermAlternateName

GO
