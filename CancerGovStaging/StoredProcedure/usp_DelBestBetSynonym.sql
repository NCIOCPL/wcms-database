IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_DelBestBetSynonym]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_DelBestBetSynonym]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_DelBestBetSynonym    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_DelBestBetSynonym
(
	@SynonymID uniqueidentifier
)
AS
	SET NOCOUNT OFF;
DELETE FROM BestBetSynonyms 
WHERE (SynonymID = @SynonymID)

GO
