IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetBestBetCategories]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetBestBetCategories]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/****** Object:  Stored Procedure dbo.usp_GetBestBetCategories    Script Date: 10/5/2001 10:45:49 AM ******/

CREATE PROCEDURE dbo.usp_GetBestBetCategories
AS
	SET NOCOUNT ON;
SELECT CategoryID, CatName, CatProfile, ListID FROM CancerGovStaging..BestBetCategories
ORDER BY CatName
GO
