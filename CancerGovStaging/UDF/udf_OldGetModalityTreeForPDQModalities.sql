IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_OldGetModalityTreeForPDQModalities]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_OldGetModalityTreeForPDQModalities]
GO

CREATE FUNCTION dbo.udf_OldGetModalityTreeForPDQModalities 
	( 
	@PDQModalityList varchar(8000),
	@ReturnExcluded char(1) = 'N'
	)
RETURNS @ResultTable TABLE
	(
	ModalityID     uniqueidentifier
	)
AS

BEGIN
	DECLARE @Modality uniqueidentifier

	IF @ReturnExcluded = 'N'
	BEGIN
		DECLARE ModalityRoot_Cursor CURSOR FOR 
		SELECT dbo.GetCancerGovTermID(ObjectID) AS ModalityID
		FROM dbo.udf_GetComaSeparatedInclusionIDs (@PDQModalityList)	
	END
	ELSE
	BEGIN
		DECLARE ModalityRoot_Cursor CURSOR FOR 
		SELECT dbo.GetCancerGovTermID(ObjectID) AS ModalityID
		FROM dbo.udf_GetComaSeparatedExclusionIDs (@PDQModalityList)	
	END

	OPEN 	ModalityRoot_Cursor
	FETCH NEXT FROM ModalityRoot_Cursor INTO @Modality

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO @ResultTable ( ModalityID ) 
		SELECT ModalityID FROM dbo.udf_GetModalityTree ( @Modality,  0 )

		FETCH NEXT FROM ModalityRoot_Cursor INTO @Modality
	END

	CLOSE ModalityRoot_Cursor
	DEALLOCATE ModalityRoot_Cursor

	RETURN
END



GO
