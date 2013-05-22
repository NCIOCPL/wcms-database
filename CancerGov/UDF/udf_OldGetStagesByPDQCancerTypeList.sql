IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_OldGetStagesByPDQCancerTypeList]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_OldGetStagesByPDQCancerTypeList]
GO
-- Used to populate PDQCancerTypeStages in data load process
CREATE FUNCTION dbo.udf_OldGetStagesByPDQCancerTypeList
	( 
	@PDQCancerType varchar(2000)
	)
RETURNS @ResultTable TABLE
	(
	StageID     uniqueidentifier,
	Stage	varchar(255)
	)
AS

BEGIN
	DECLARE 	@StageFamilyID uniqueidentifier

	DECLARE Stage_Cursor CURSOR FOR 
	SELECT dbo.GetCancerGovTermID( ObjectID ) AS StageFamilyID
	FROM 	dbo.udf_GetComaSeparatedIDs( @PDQCancerType) 

	OPEN 	Stage_Cursor
	FETCH NEXT FROM Stage_Cursor INTO @StageFamilyID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO 	@ResultTable (StageID, Stage) 
		SELECT StageID, Stage FROM dbo.udf_GetStagesByCancerType( @StageFamilyID )

		FETCH NEXT FROM Stage_Cursor INTO @StageFamilyID
	END

	CLOSE Stage_Cursor
	DEALLOCATE Stage_Cursor

	RETURN
END


GO
