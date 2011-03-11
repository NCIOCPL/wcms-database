IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolDrugs]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolDrugs]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE usp_GetProtocolDrugs 
AS
BEGIN
	DECLARE 	@RelationTypeID	uniqueidentifier
	SELECT 	@RelationTypeID = dbo.GetCancerGovTypeID(208)
	
	SELECT 	DISTINCT T.TermID,	-- DRUI 
			T.[Name], 		-- DRUG
			Priority = 2	
	FROM		ProtocolRelatedTerm PRT, 
			Terminology T
	WHERE	PRT.TermID = T.TermID
			AND PRT.RelationTypeID = @RelationTypeID
	ORDER BY 	Priority, [Name]
END

GO
