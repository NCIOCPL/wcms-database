IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetModalityTree]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetModalityTree]
GO
CREATE FUNCTION dbo.udf_GetModalityTree
	( 
	@RootModality uniqueidentifier,
	@StatingLevel int = 0 
	)
RETURNS @ResultTable TABLE
	(
	ModalityID     uniqueidentifier,
	Modality	varchar(255),
	ChildLevel	int
	)
AS

BEGIN
	DECLARE @OnLineStatusID   uniqueidentifier,
		@CancerInfoProduct uniqueidentifier,
		@ModalityType uniqueidentifier,
		@ModalityKid uniqueidentifier,
		@KidLevel int 

	SELECT  @ModalityType = dbo.GetCancerGovTypeID( 202 ),
		@OnLineStatusID = dbo.GetCancerGovStatusID(66), -- on-line
		@CancerInfoProduct = dbo.GetCancerGovTypeID(456),
		@KidLevel = @StatingLevel + 1
	
	DECLARE ModalityChilldren_Cursor CURSOR FOR 
	SELECT  T.TermID 
	FROM 	Terminology AS T	
		INNER JOIN TermRelations AS TR
			ON T.TermID = TR.RelatedTermID 
			AND  T.StatusID = @OnLineStatusID	
		INNER JOIN TermType AS TT 
			ON TR.RelatedTermID = TT.TermID
			AND TR.ProductID = @CancerInfoProduct 			
			AND TR.RelationType = @ModalityType 
			AND TT.Type = @ModalityType 			
	WHERE TR.TermID = @RootModality 

	OPEN 	ModalityChilldren_Cursor
	FETCH NEXT FROM ModalityChilldren_Cursor INTO @ModalityKid 

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		INSERT INTO @ResultTable ( ModalityID, Modality, ChildLevel) 
		SELECT ModalityID, Modality, ChildLevel FROM dbo.udf_GetModalityTree ( @ModalityKid,  @KidLevel )

		FETCH NEXT FROM ModalityChilldren_Cursor INTO @ModalityKid 
	END

	CLOSE ModalityChilldren_Cursor
	DEALLOCATE ModalityChilldren_Cursor

	INSERT INTO @ResultTable ( ModalityID, Modality, ChildLevel) 
	SELECT 	T.TermID,
			T.[Name],
			@StatingLevel
	FROM 	Terminology AS T	
	WHERE T.TermID = @RootModality 

	RETURN
END












GO
