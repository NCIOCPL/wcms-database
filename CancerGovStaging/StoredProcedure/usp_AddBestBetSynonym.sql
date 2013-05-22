IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_AddBestBetSynonym]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_AddBestBetSynonym]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_AddBestBetSynonym    Script Date: 10/5/2001 10:45:48 AM ******/
CREATE PROCEDURE dbo.usp_AddBestBetSynonym
(
	@SynonymID uniqueidentifier,
	@CategoryID uniqueidentifier,
	@SynName varchar(50)
)
AS
	SET NOCOUNT OFF;
INSERT INTO BestBetSynonyms
(SynonymID, CategoryID, SynName) 
VALUES 
(@SynonymID, @CategoryID, @SynName);

SELECT SynonymID, CategoryID, SynName 
FROM BestBetSynonyms 
WHERE (SynonymID = @SynonymID)

GO
