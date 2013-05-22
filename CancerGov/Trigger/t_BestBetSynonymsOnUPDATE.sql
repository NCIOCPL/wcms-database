/****** Object:  Trigger [t_BestBetSynonymsOnUPDATE]    Script Date: 01/09/2008 14:32:38 ******/
IF   OBJECT_ID(N'[dbo].[t_BestBetSynonymsOnUPDATE]') is not NULL
DROP TRIGGER [dbo].[t_BestBetSynonymsOnUPDATE]
GO
/****** Object:  Trigger [dbo].[t_BestBetSynonymsOnUPDATE]    Script Date: 01/09/2008 14:32:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[t_BestBetSynonymsOnUPDATE] ON [dbo].[BestBetSynonyms] 
FOR UPDATE
AS
BEGIN
	INSERT INTO AuditBestBetSynonyms (AuditActionType,
		SynonymID,
		CategoryID,
		SynName,
		Notes,
		IsNegated,
		UpdateDate,
		UpdateUserID,
		isExactMatch )
	SELECT 'UPDATE' as AuditActionType,
		tbl.SynonymID,
		tbl.CategoryID,
		tbl.SynName,
		tbl.Notes,
		tbl.IsNegated,
		tbl.UpdateDate,
		tbl.UpdateUserID ,
		tbl.isExactMatch
	FROM 	inserted tbl
END












