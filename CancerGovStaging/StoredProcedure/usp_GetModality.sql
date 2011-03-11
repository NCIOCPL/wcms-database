IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetModality]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetModality]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE usp_GetModality 
AS
BEGIN
	DECLARE 	@RelationTypeID		uniqueidentifier
	SELECT 	@RelationTypeID = dbo.GetCancerGovTypeID(202)

	SELECT 	TermID = null, 
			[Name] = 'All', 
			Priority = 1
	UNION
	SELECT 	DISTINCT T.TermID, 
			T.[Name], 
			Priority = 2
	FROM		ProtocolRelatedTerm PRT, Terminology T
	WHERE 	PRT.TermID = T.TermID	
			AND PRT.RelationTypeID = @RelationTypeID 
	ORDER BY 	Priority, [Name]
END

GO
