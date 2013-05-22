IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolPhases]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolPhases]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetProtocolPhases 
AS
BEGIN
	DECLARE @RelationTypeID		uniqueidentifier
	
	SELECT @RelationTypeID = dbo.GetCancerGovTypeID(205)
	
	SELECT 	TermID = null, 
			[Name] = 'all phases', 
			Priority = 0
	UNION
	SELECT 	DISTINCT T.TermID,	-- PHUI 
			T.[Name],		-- PHAS 
			Priority = 1		
	FROM		ProtocolRelatedTerm PRT, 
			Terminology T
	WHERE 	PRT.TermID = T.TermID
			AND PRT.RelationTypeID = @RelationTypeID
			AND T.[Name] Like 'phase %'
	UNION
	SELECT 	DISTINCT T.TermID,	-- PHUI 
			T.[Name], 		-- PHAS
			Priority = 2	
	FROM		ProtocolRelatedTerm PRT, 
			Terminology T
	WHERE 	PRT.TermID = T.TermID
			AND PRT.RelationTypeID = @RelationTypeID
			AND T.[Name] Not Like 'phase %'
	ORDER BY 	Priority, [Name]
END

GO
