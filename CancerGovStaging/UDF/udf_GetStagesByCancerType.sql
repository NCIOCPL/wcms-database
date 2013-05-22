IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetStagesByCancerType]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetStagesByCancerType]
GO
CREATE FUNCTION dbo.udf_GetStagesByCancerType
	( 
	--@PDQCancerType int
	@aCancerType uniqueidentifier
	)
RETURNS @ResultTable TABLE
	(
	StageID     uniqueidentifier,
	Stage	varchar(255)
	)
AS

BEGIN
	DECLARE 	@StageTerm uniqueidentifier,
			@StageFamily uniqueidentifier,
			@OnLineStatusID   uniqueidentifier,
			@CancerType  uniqueidentifier,
			@CancerInfoProduct uniqueidentifier,
			@DiagnosisRelationType uniqueidentifier,
			@StageFamilyID uniqueidentifier

	SELECT 	@StageTerm  = dbo.GetCancerGovTypeID(203),
			@StageFamily = dbo.GetCancerGovTypeID(225),
			@OnLineStatusID = dbo.GetCancerGovStatusID(66), -- on-line
			--@CancerType  = CancerGov.dbo.GetCancerGovTermID( @PDQCancerType ),
			@CancerType = @aCancerType,
			@CancerInfoProduct = dbo.GetCancerGovTypeID(456),
			@DiagnosisRelationType = dbo.GetCancerGovTypeID(137)
	
	DECLARE StageFamily_Cursor CURSOR FOR 
	SELECT 	TR.RelatedTermID
	FROM 		TermRelations TR 
			INNER JOIN TermType AS TT 
				ON TR.RelatedTermID = TT.TermID
				AND TR.TermID = @CancerType 
				AND TR.ProductID = @CancerInfoProduct 			
				AND (	
					TT.Type = @StageFamily --stage 225
					OR TT.Type = @StageTerm --stage 203
					)				
				AND TR.RelationType = @DiagnosisRelationType

	OPEN 	StageFamily_Cursor
	FETCH NEXT FROM StageFamily_Cursor INTO @StageFamilyID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO 	@ResultTable (StageID, Stage) 
		SELECT StageID, Stage FROM dbo.udf_GetStagesByCancerType( @StageFamilyID)

		FETCH NEXT FROM StageFamily_Cursor INTO @StageFamilyID
	END

	CLOSE StageFamily_Cursor
	DEALLOCATE StageFamily_Cursor

	INSERT INTO 	@ResultTable (StageID, Stage)
	SELECT	T.TermID,
			T.[Name]
	FROM		Terminology AS T
			INNER JOIN TermType AS TT 
				ON T.TermID = TT.TermID
				AND TT.Type = @StageTerm --stage 203
				AND T.StatusID = @OnLineStatusID  -- on-line
			INNER JOIN TermRelations AS TR
				ON T.TermID = TR.RelatedTermID
				AND TR.ProductID = @CancerInfoProduct 			
				AND TR.TermID = @CancerType
				AND TR.RelationType = @DiagnosisRelationType

	RETURN
END








GO
