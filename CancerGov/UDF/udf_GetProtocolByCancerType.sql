IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProtocolByCancerType]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProtocolByCancerType]
GO
CREATE FUNCTION [dbo].[udf_GetProtocolByCancerType] 
	( 
	@PDQCancerType varchar(200), 
	@IsActiveProtocol varchar(1) ,
	@ReturnExcluded char(1) = 'N'
	)  
RETURNS @ResultTable TABLE
	(
	ProtocolID	uniqueidentifier 
	)
AS  

BEGIN 
	/*PROTOCOL by TYPE OF CANCER*/
	DECLARE @Product uniqueidentifier,
		@Diagnosis   uniqueidentifier,
		@OnLine uniqueidentifier

	SELECT 	@Product  = dbo.GetCancerGovTypeID(456),	-- Cancer Information Product   
			@Diagnosis  = dbo.GetCancerGovTypeID(137), -- diagnosis  
			@OnLine =  dbo.GetCancerGovStatusID(66)  --Online status
	
	IF @ReturnExcluded <> 'Y'
	BEGIN
		SELECT @ReturnExcluded = 'N'
	END

	IF (@ReturnExcluded = 'N')
	BEGIN 
		IF ((SELECT count(*) FROM dbo.udf_GetComaSeparatedInclusionIDs(@PDQCancerType)) > 0)
		BEGIN
			INSERT INTO @ResultTable
			SELECT  distinct ProtocolID
			FROM 	ProtocolRelatedTerm PRT 
			WHERE 
				PRT.ProductID = dbo.GetCancerGovTypeID(456) 			-- Cancer Information Product   
				AND	PRT.RelationTypeID =  dbo.GetCancerGovTypeID(137) 	-- diagnosis  
				AND 	PRT.TermID IN (
							SELECT  TA.TermID 
							FROM 	TermAncestor TA INNER JOIN (
										SELECT 	T.TermID 
										FROM 	Terminology AS T 
											INNER JOIN 
											(SELECT CONVERT(int,ObjectID) AS PDQSourceID 
											 FROM dbo.udf_GetComaSeparatedInclusionIDs(@PDQCancerType)) AS CT
											ON T.SourceID  = CT.PDQSourceID
										WHERE  StatusID = @OnLine 
										) AS TTT
								ON TA.AncestorID = TTT.TermID 
								INNER JOIN Terminology AS MT
								ON TA.TermID = MT.TermID
								AND MT.StatusID = @OnLine 
							WHERE  ProductTypeID =  @Product 			-- Cancer Information Product   
								--AND AncestorLevel <= 3
						
							UNION
							SELECT 	TermID 
							FROM 	dbo.Terminology AS T 
								INNER JOIN 
								(SELECT CONVERT(int,ObjectID) AS PDQSourceID FROM dbo.udf_GetComaSeparatedInclusionIDs(@PDQCancerType)) AS CT
								ON T.SourceID  = CT.PDQSourceID
							WHERE  StatusID = @OnLine 
							)  
		END
		ELSE
		BEGIN
			IF @IsActiveProtocol = 'Y'
			BEGIN
				INSERT INTO @ResultTable 
				SELECT ProtocolID FROM vwActiveProtocol
			END 
			ELSE 
			BEGIN
				INSERT INTO @ResultTable 
				SELECT ProtocolID FROM vwNotActiveProtocol
			END 
		END 
	END
	ELSE BEGIN
		IF ((SELECT count(*) FROM dbo.udf_GetComaSeparatedExclusionIDs(@PDQCancerType)) > 0)
		BEGIN
			INSERT INTO @ResultTable
			SELECT  distinct ProtocolID
			FROM 	ProtocolRelatedTerm PRT 
			WHERE 
				PRT.ProductID = dbo.GetCancerGovTypeID(456) 			-- Cancer Information Product   
				AND	PRT.RelationTypeID =  dbo.GetCancerGovTypeID(137) 	-- diagnosis  
				AND 	PRT.TermID IN (
							SELECT  TA.TermID 
							FROM 	TermAncestor TA INNER JOIN (
										SELECT 	T.TermID 
										FROM 	Terminology AS T 
											INNER JOIN 
											(SELECT CONVERT(int,ObjectID) AS PDQSourceID 
											 FROM dbo.udf_GetComaSeparatedExclusionIDs(@PDQCancerType)) AS CT
											ON T.SourceID  = CT.PDQSourceID
										WHERE  StatusID = @OnLine 
										) AS TTT
								ON TA.AncestorID = TTT.TermID 
								INNER JOIN Terminology AS MT
								ON TA.TermID = MT.TermID
								AND MT.StatusID = @OnLine 
							WHERE  ProductTypeID =  @Product 			-- Cancer Information Product   
								--AND AncestorLevel <= 3
						
							UNION
							SELECT 	TermID 
							FROM 	dbo.Terminology AS T 
								INNER JOIN 
								(SELECT CONVERT(int,ObjectID) AS PDQSourceID FROM dbo.udf_GetComaSeparatedExclusionIDs(@PDQCancerType)) AS CT
								ON T.SourceID  = CT.PDQSourceID
							WHERE  StatusID = @OnLine 
							)  
		END
		ELSE
		BEGIN
			IF @IsActiveProtocol = 'Y'
			BEGIN
				INSERT INTO @ResultTable
				SELECT ProtocolID FROM vwActiveProtocol
			END 
			ELSE 
			BEGIN
				INSERT INTO @ResultTable
				SELECT ProtocolID FROM vwNotActiveProtocol
			END 
		END
	END

	RETURN
END


GO
