IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetAllModalities]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetAllModalities]
GO
CREATE FUNCTION dbo.udf_GetAllModalities()
RETURNS @ResultTable TABLE
	(
	ModalityID     	uniqueidentifier,
	Modality	varchar(255)
	)
AS

BEGIN
	DECLARE 	@ModalityTypeID uniqueidentifier,
			@CombinationChemotherapyTypeID uniqueidentifier,
			@OnLineStatusID   	uniqueidentifier,
			@PrimaryTermType	uniqueidentifier
	SELECT 	@ModalityTypeID = dbo.GetCancerGovTypeID( 202 ),
			@CombinationChemotherapyTypeID = dbo.GetCancerGovTypeID( 200 ),
			@OnLineStatusID = dbo.GetCancerGovStatusID( 66 ), -- on-line
			@PrimaryTermType = dbo.GetCancerGovTypeID( 58 )
	
	INSERT INTO 	@ResultTable (ModalityID, Modality)
	SELECT	T.TermID,
			T.[Name]
	FROM		Terminology T
			INNER JOIN TermType TT 
			ON T.TermID = TT.TermID
			AND TT.Type = @ModalityTypeID 
			AND T.StatusID = @OnLineStatusID  -- on-line
			AND TypeOfType = @PrimaryTermType 
	WHERE 	T.TermID NOT IN ( SELECT TermID FROM  TermType WHERE Type = @CombinationChemotherapyTypeID )

	RETURN
END


















GO
