IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetAllStages]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetAllStages]
GO
CREATE FUNCTION dbo.udf_GetAllStages()
RETURNS @ResultTable TABLE
	(
	StageID     uniqueidentifier,
	Stage	varchar(255)
	)
AS

BEGIN
	DECLARE 	@StageTerm uniqueidentifier,
			@OnLineStatusID   uniqueidentifier
	SELECT 	@StageTerm  = dbo.GetCancerGovTypeID(203),
			@OnLineStatusID = dbo.GetCancerGovStatusID(66) -- on-line
	
	INSERT INTO @ResultTable (StageID, Stage)
	SELECT	T.TermID,
			T.[Name]
	FROM		Terminology T
			INNER JOIN TermType TT 
			ON T.TermID = TT.TermID
			AND TT.Type = @StageTerm --stage 203
			AND T.StatusID = @OnLineStatusID  -- on-line
			--AND UPPER(T.[Name]) like 'STAGE%'
	RETURN
END















GO
