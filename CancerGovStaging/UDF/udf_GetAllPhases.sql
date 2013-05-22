IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetAllPhases]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetAllPhases]
GO
CREATE FUNCTION dbo.udf_GetAllPhases()
RETURNS @ResultTable TABLE
	(
	PhaseID     	uniqueidentifier,
	Phase		varchar(255)
	)
AS

BEGIN
	DECLARE 	@PhaseRelationTypeID  	uniqueidentifier,
			@OnLineStatusID   	uniqueidentifier,
			@PrimaryTermType	uniqueidentifier
	SELECT 	@PhaseRelationTypeID = dbo.GetCancerGovTypeID( 205 ), --protocol phase   
			@OnLineStatusID = dbo.GetCancerGovStatusID( 66 ), -- on-line
			@PrimaryTermType = dbo.GetCancerGovTypeID( 58 )
	
	
	INSERT INTO @ResultTable (PhaseID, Phase)
	SELECT		T.TermID,
			T.[Name]
	FROM		Terminology T
			INNER JOIN TermType TT 
			ON T.TermID = TT.TermID
			AND TT.Type = @PhaseRelationTypeID 
			AND T.StatusID = @OnLineStatusID  -- on-line
			AND TypeOfType = @PrimaryTermType 
	RETURN
END


















GO
