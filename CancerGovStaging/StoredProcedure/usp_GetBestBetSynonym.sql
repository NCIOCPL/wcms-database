IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetBestBetSynonym]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetBestBetSynonym]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_GetBestBetSynonym    Script Date: 10/5/2001 10:45:49 AM ******/
CREATE PROCEDURE dbo.usp_GetBestBetSynonym
	@CategoryID   uniqueidentifier

AS
	SET NOCOUNT ON;
SELECT SynonymID, CategoryID, SynName 
FROM CancerGovStaging..BestBetSynonyms
Where CategoryID = @CategoryID
GO
