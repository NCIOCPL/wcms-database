IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_UpdateBestBetSynonym]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_UpdateBestBetSynonym]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_UpdateBestBetSynonym    Script Date: 10/5/2001 10:45:49 AM ******/
CREATE PROCEDURE dbo.usp_UpdateBestBetSynonym
(
	@SynonymID uniqueidentifier,
	@SynName varchar(50)
)
AS
	SET NOCOUNT OFF;
UPDATE BestBetSynonyms SET SynName = @SynName 
WHERE (SynonymID = @SynonymID);

SELECT SynonymID, CategoryID, SynName 
FROM BestBetSynonyms 
WHERE (SynonymID = @SynonymID)

GO
