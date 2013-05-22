IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_ProtocolSearch]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_ProtocolSearch]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure perform Clinical Trial Search 
*
*	Objects Used:
*	CancerGov..ProtocolRelatedTerm - table
*
*	Change History:
*	?/?/2001 	Alex Pidlisnyy	Script Created
*	?/?/2001-2002 	Alex Pidlisnyy	Update Procedure
*	?/?/2001-2002 	Greg Andres	Update Procedure
*	2/5/2002 	Alex Pidlisnyy	Add AlternateIDs pattern search functionality
*
*/

CREATE PROCEDURE usp_ProtocolSearch
	(	
	/* General search parameters */
	@AlternateProtocolID 	varchar(1000) 	= null,
	@CancerType		varchar(200) = null,	-- PDQ TypeID 
	@Status		varchar(5) = null,	-- 'Y' - Yes, 'N'-No, NULL - das not mater  
	@TrialType		varchar(50) = null, 	-- about 6 PDQ identifiers 
	@City			varchar(100) = null,
	@StateID		varchar(2000) = null, 	-- 53 unique identifiers maximum
	@CountryID		uniqueidentifier = null,
	@NihOnly		char(1) = null,		-- 'Y' - Yes, 'N'-No, NULL - das not mater  
	/* Additional search parameters */
	@Modality		varchar(1000) = null,
	@CancerStages	varchar(500) = null,
	@Drug			varchar(100) = null,	-- only one drug (nameof drug)
	@PhaseOfTrial		varchar(500) = null,
	@SponsorOfTrial	varchar(500) = null,
	@NewOnly		char(1) = null,		-- 'Y' - Yes, 'N'-No, NULL - das not mater  
	@Organization		varchar(1000) = null 	-- 'PDQ Organization IDs'
	)
AS
BEGIN
	PRINT 'DECLARE VARIABLES'
	CREATE TABLE #tmpProtocolScope(
		ProtocolID uniqueidentifier,
		Title varchar(2000),
		IsNew char(1)
	)
	--table will hold Protocols found by Alternate IDs 
	CREATE TABLE #tmpAlternateProtocolID (
		ProtocolID uniqueidentifier
	)


	DECLARE 	@PDQProtocolProductID uniqueidentifier,
			@ModalityRelationTypeID uniqueidentifier,
			@PhaseRelationTypeID uniqueidentifier,
			@OrgRoleID uniqueidentifier,
			@AdditionalSearch char(1), 
		 	@ProductID uniqueidentifier,
			@OnLineStatusID uniqueidentifier,
			@Exclusion uniqueidentifier,
			@AlternateProtocolIDPattern varchar(50)
 

		PRINT 'CHECK INCOMING PARAMETERS'
		SELECT @CancerStages = NULLIF( LTRIM(RTRIM(@CancerStages)), ''),
			@PhaseOfTrial = NULLIF( LTRIM(RTRIM(@PhaseOfTrial)), ''),
			@Drug = NULLIF( LTRIM(RTRIM(@Drug)), ''),
			@Modality = NULLIF( LTRIM(RTRIM(@Modality)), ''),
			@SponsorOfTrial = NULLIF( LTRIM(RTRIM(@SponsorOfTrial)), ''),
			@NewOnly = NULLIF( LTRIM(RTRIM(@NewOnly)), ''),
			@Organization = NULLIF(LTRIM(RTRIM(@Organization)), '')

		IF ((@Modality IS NOT NULL) OR (@CancerStages IS NOT NULL) OR (@Drug IS NOT NULL) OR 
			(@PhaseOfTrial IS NOT NULL) OR (@SponsorOfTrial IS NOT NULL) OR (@NewOnly IS NOT NULL))
		BEGIN
			SELECT @AdditionalSearch = 'Y'
		END
		ELSE 	
		BEGIN
			SELECT @AdditionalSearch = 'N'
		END 

		SELECT @StateID = NULLIF( LTRIM(RTRIM(@StateID)), ''),
			@TrialType = NULLIF( LTRIM(RTRIM(@TrialType)), ''),
			@NihOnly = NULLIF( LTRIM(RTRIM(@NihOnly)), ''),
			@CancerType = NULLIF( LTRIM(RTRIM(@CancerType)), ''),
			@City = NULLIF( LTRIM(RTRIM(UPPER(@City))), '')

		PRINT 'SET DEFAULT VARIABLES'
		SELECT @ModalityRelationTypeID = dbo.GetCancerGovTypeID(202) , 
			@PhaseRelationTypeID = dbo.GetCancerGovTypeID(205),
			@OrgRoleID = dbo.GetCancerGovOrgRoleID(69), -- lead organization           
			@PDQProtocolProductID = dbo.GetCancerGovTypeID(456),
			@ProductID = dbo.GetCancerGovTypeID(456), -- Cancer Information Product   
			@OnLineStatusID = dbo.GetCancerGovStatusID(66) -- on-line

		PRINT '**** START SEARCH ****'
		PRINT 'FIND ALL TRIALS FOR GIVEN TRIAL_TYPE AND CANCER_TYPE'
		If 	(@TrialType IS NOT NULL)
			OR (@CancerType IS NOT NULL) 
		BEGIN
			PRINT '---- TRIAL_TYPE OR CANCER_TYPE PROVIDED'
			IF (@Status ='Y')
			BEGIN
				PRINT '---- STATUS IS OPEN/ACTIVE'
				INSERT INTO  #tmpProtocolScope
				SELECT DISTINCT 
					P.ProtocolID, P.Title, P.IsNew 
				FROM 	vwActiveProtocol AS P		
					INNER JOIN ProtocolType AS PT
						ON P.ProtocolID = PT.ProtocolID 
						AND PT.ProductID = @PDQProtocolProductID
						AND ((@TrialType  IS NOT NULL) AND (PT.Type IN (SELECT dbo.GetCancerGovTypeID(ObjectID) as TypeID FROM dbo.udf_GetComaSeparatedIDs (@TrialType))) OR @TrialType  IS NULL )
					INNER JOIN (SELECT ProtocolID FROM udf_GetProtocolByCancerType (   @CancerType , @Status, 'N'  )      ) AS  PRT
						ON P.ProtocolID = PRT.ProtocolID 
				WHERE 	((@NihOnly IS NOT NULL) AND (P.IsNCIProtocol = 'Y') OR @NihOnly IS NULL) 
						AND P.IsReadyForWeb = 'Y'
			END
			ELSE 
			BEGIN
				PRINT '---- STATUS IS CLOSED'
				INSERT INTO  #tmpProtocolScope
				SELECT DISTINCT 
					P.ProtocolID, P.Title, P.IsNew 
				FROM 	vwNotActiveProtocol AS P		
					INNER JOIN ProtocolType AS PT
						ON P.ProtocolID = PT.ProtocolID 
						AND PT.ProductID = @PDQProtocolProductID
						AND ((@TrialType IS NOT NULL) AND (PT.Type IN (SELECT dbo.GetCancerGovTypeID(ObjectID) as TypeID FROM dbo.udf_GetComaSeparatedIDs (@TrialType))) OR  @TrialType IS NULL )
					INNER JOIN (SELECT ProtocolID FROM udf_GetProtocolByCancerType (   @CancerType , @Status, 'N'  )      ) AS  PRT
						ON P.ProtocolID = PRT.ProtocolID 
				WHERE 	((@NihOnly IS NOT NULL) AND (P.IsNCIProtocol = 'Y') OR @NihOnly IS NULL) 
						AND P.IsReadyForWeb = 'Y'
			END
		END 
		ELSE BEGIN
			PRINT '---- TRIAL_TYPE AND CANCER_TYPE NOT PROVIDED'
			IF (@Status ='Y')
			BEGIN
				PRINT '---- STATUS IS OPEN/ACTIVE'
				INSERT 	INTO  #tmpProtocolScope
				SELECT 	P.ProtocolID, 
						P.Title, 
						P.IsNew 
				FROM 		vwActiveProtocol AS P		
				WHERE 	((@NihOnly IS NOT NULL) AND (P.IsNCIProtocol = 'Y') OR @NihOnly IS NULL) 
					AND P.IsReadyForWeb = 'Y'
			END
			ELSE 
			BEGIN
				PRINT '---- STATUS IS CLOSED'
				INSERT 	INTO  #tmpProtocolScope
				SELECT 	P.ProtocolID, 
						P.Title, 
						P.IsNew 
				FROM 		vwNotActiveProtocol AS P		
				WHERE 	((@NihOnly IS NOT NULL) AND (P.IsNCIProtocol = 'Y') OR @NihOnly IS NULL) 
					AND P.IsReadyForWeb = 'Y'
			END
		END

		PRINT 'CHECK PROTOCOL LOCATION INFO'
		If 	(@City IS NOT NULL)	
			OR (@StateID IS NOT NULL)	
			OR (@CountryID IS NOT NULL)
		BEGIN
			PRINT '---- SELECT PROTOCOLS FOR GIVEN LOCATION'
			DELETE #tmpProtocolScope
			WHERE  ProtocolID NOT IN (
					SELECT 	P.ProtocolID
					FROM 	#tmpProtocolScope AS P		
						INNER JOIN dbo.ProtocolStudyContact  AS L 
							ON P.ProtocolID = L.ProtocolID 
							AND((@City IS NOT NULL) AND (L.City = @City) OR @City IS NULL  )
							AND((@StateID IS NOT NULL) AND (L.StateID IN (SELECT CONVERT(uniqueidentifier, ObjectID) FROM dbo.udf_GetComaSeparatedIDs ( @StateID ))) OR (@StateID IS NULL))
							AND ((@CountryID IS NOT NULL) AND (L.CountryID = @CountryID) OR (@CountryID IS NULL))
				)
		END 

		PRINT 'CHECK PROTOCOL ALTERNATE IDs'
		IF ISNULL(@AlternateProtocolID,'') <> '' 
		BEGIN

			--Perform AlternateIDs Pattern Search 
			DECLARE AlternateIDs_Cursor CURSOR LOCAL FOR 
			SELECT '%' + LTRIM(RTRIM(ObjectID)) + '%' 
			FROM	udf_GetComaSeparatedIDs( @AlternateProtocolID )
			
			OPEN AlternateIDs_Cursor
			FETCH NEXT FROM AlternateIDs_Cursor INTO @AlternateProtocolIDPattern
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO 	#tmpAlternateProtocolID
				SELECT 	ProtocolID  
				FROM		ProtocolAlternateID
				WHERE 	AlternateID like ( @AlternateProtocolIDPattern )
			
				FETCH NEXT FROM AlternateIDs_Cursor INTO @AlternateProtocolIDPattern
			END
			
			CLOSE AlternateIDs_Cursor
			DEALLOCATE AlternateIDs_Cursor
			

			--Delete Protocols which do not meet search creteria
			DELETE  #tmpProtocolScope 
			WHERE  ProtocolID NOT IN (
							SELECT ProtocolID  
							FROM 	#tmpAlternateProtocolID 
						)
		END


		PRINT 'REMOVE PROTOCOLS BY EXCLUSION CANCERTYPE'
		IF ((SELECT count(*) FROM dbo.udf_GetComaSeparatedExclusionIDs(@CancerType)) > 0)
		BEGIN
			DELETE
			FROM #tmpProtocolScope	
			WHERE ProtocolID IN (
							SELECT ProtocolID
							FROM udf_GetProtocolByCancerType(@CancerType, 'Y', 'Y')
						)
		END

		PRINT 'SEARCH BY ORGANIZATION'
		IF ((SELECT count(*) FROM dbo.udf_GetComaSeparatedInclusionIDs(@Organization)) > 0)
		BEGIN
			DELETE
			FROM #tmpProtocolScope	
			WHERE ProtocolID NOT IN (
				SELECT DISTINCT po.ProtocolID
				FROM ProtocolOrganization po INNER JOIN Organization o ON po.OrganizationID = o.OrganizationID
				WHERE o.SourceID IN (SELECT ObjectID FROM udf_GetComaSeparatedInclusionIDs(@Organization))
			)
		END


		PRINT 'SEARCH BY ADDITIONAL CRETEREA'
		IF (@AdditionalSearch = 'N') 
		BEGIN 
			PRINT 'NO ADDITIONAL CRETEREA PROVIDED'
			--GET Search Result BEFORE other recordsets
			SELECT ProtocolID, 
				Title, 
				dbo.udf_GetProtocolAlternateIDs(ProtocolID) AS AlternateIDs --'TTTTTT-1' As AlternateIDs
			FROM  #tmpProtocolScope
			ORDER BY Title
			
			PRINT 'POPULATE STAGES FOR FOUND TRIALS'
			--Populate Stage for protocols
			IF ((SELECT count(*) FROM dbo.udf_GetComaSeparatedInclusionIDs(@CancerType)) > 0)
			BEGIN
				PRINT 'Start Stages'
				SELECT 	StageID = null, 
					[Name] = ' all', 
					Priority = 1
				UNION	
				SELECT LTRIM(RTRIM(Stage))+ ';' + convert(varchar(36),StageID) AS StageID, 
					Stage  AS [Name],
					Priority = 2
				--FROM 	dbo.udf_GetStagesByCancerType( @tmpCancerTypeID  ) AS S
				--FROM 	dbo.udf_GetStagesByCancerType( @CancerType  ) AS S
				FROM 	dbo.udf_GetStagesByPDQCancerTypeList( @CancerType  ) AS S
					INNER JOIN ProtocolRelatedTerm PRT 
					ON S.StageID = PRT.TermID
					INNER JOIN #tmpProtocolScope TP
					ON TP.ProtocolID = PRT.ProtocolID  
				ORDER BY [Name]
				PRINT 'End Stages'
			END 
			ELSE BEGIN 
				PRINT 'No Stages'
				SELECT 	StageID = null, 
					[Name] = ' all', 
					Priority = 1
			END 
			
			PRINT 'POPULATE PHASES  FOR FOUND TRIALS'
			--Populate Phases for found protocols
			SELECT 	PhaseID = null, 
					[Name] = ' all', 
					Priority = 0
			UNION
			SELECT 
				LTRIM(RTRIM(P.Phase)) + ';' + convert(varchar(36),P.PhaseID) AS PhaseID,
				P.Phase AS [Name] ,
				Priority = 2
			FROM 	dbo.udf_GetAllPhases() AS P 
				INNER JOIN  ProtocolRelatedTerm AS PRT 
					ON PRT.TermID = P.PhaseID 
					--AND PRT.RelationTypeID = @PhaseRelationTypeID  -- protocol phase    
				INNER JOIN #tmpProtocolScope TP
					ON TP.ProtocolID = PRT.ProtocolID  
					--AND PRT.ProtocolID IN ( SELECT ProtocolID  FROM #tmpProtocolScope )
	
		END 
		ELSE --Additional search 
		BEGIN
			PRINT 'ADDITIONAL CRITERIA PROVIDED'
			IF (@Modality IS NOT NULL) 
			BEGIN
				PRINT '---- CHECK FOR MODALITY'
				
				IF ((SELECT count(*) FROM dbo.udf_GetComaSeparatedInclusionIDs(@Modality)) > 0)
				BEGIN
					DELETE  #tmpProtocolScope 
					WHERE  ProtocolID NOT IN 
						(
						SELECT TP.ProtocolID
						FROM 	#tmpProtocolScope TP 
							INNER JOIN ProtocolRelatedTerm PRT 
							ON PRT.ProtocolID = TP.ProtocolID 
							AND PRT.ProductID = @ProductID  -- Cancer Information Product   
							AND PRT.TermID IN (	
								--Modality
								SELECT ModalityID AS ObjectID FROM dbo.udf_GetModalityTreeForPDQModalities ( @Modality, 'N' )	
								)
						)
				END
				ELSE
				BEGIN			
					DELETE  #tmpProtocolScope 
					WHERE  ProtocolID IN 
						(
						SELECT TP.ProtocolID
						FROM 	#tmpProtocolScope TP 
							INNER JOIN ProtocolRelatedTerm PRT 
							ON PRT.ProtocolID = TP.ProtocolID 
							AND PRT.ProductID = @ProductID  -- Cancer Information Product   
							AND PRT.TermID IN (	
								--Modality
								SELECT ModalityID AS ObjectID FROM dbo.udf_GetModalityTreeForPDQModalities ( @Modality, 'Y' )	
								)
						)
				END

			END 

			IF (@CancerStages IS NOT NULL)
			BEGIN
				PRINT '---- CHECK FOR STAGE'
				SELECT @Exclusion = CancerGov.dbo.GetCancerGovTypeID( 217 ) --     protocol selection criteria

				DELETE  #tmpProtocolScope 
				WHERE  ProtocolID NOT IN 
						(
						SELECT TP.ProtocolID
						FROM 	#tmpProtocolScope TP 
							INNER JOIN ProtocolRelatedTerm PRT 
							ON PRT.ProtocolID = TP.ProtocolID 
							AND NOT PRT.RelationTypeID = @Exclusion 
							AND PRT.ProductID = @ProductID  -- Cancer Information Product   
							AND PRT.TermID IN (	
								--Stages (including child stages)
								select 	TermID
								from 	CancerGov..TermAncestor
								where 	AncestorID IN (
											SELECT CONVERT(uniqueidentifier, LTRIM(RTRIM(ObjectID))) AS ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CancerStages  )	
											)
								)
						)
			END

			IF (@PhaseOfTrial  IS NOT NULL)
			BEGIN
				PRINT '---- CHECK FOR PHASE'
				DELETE  #tmpProtocolScope 
				WHERE  ProtocolID NOT IN 
						(
						SELECT TP.ProtocolID
						FROM 	#tmpProtocolScope TP 
							INNER JOIN ProtocolRelatedTerm PRT 
							ON PRT.ProtocolID = TP.ProtocolID 
							AND PRT.ProductID = @ProductID  -- Cancer Information Product   
							AND PRT.TermID IN (	
								--PhaseOfTrial
								SELECT CONVERT(uniqueidentifier, LTRIM(RTRIM(ObjectID))) AS ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @PhaseOfTrial ) 
								)
						)
			END	

			IF( @Drug  IS NOT NULL)
			BEGIN
				PRINT '---- CHECK FOR DRUG'
				DELETE  #tmpProtocolScope 
				WHERE  ProtocolID NOT IN 

						(
						SELECT TP.ProtocolID
						FROM 	#tmpProtocolScope TP 
							INNER JOIN ProtocolRelatedTerm PRT 
							ON PRT.ProtocolID = TP.ProtocolID 
							AND PRT.ProductID = @ProductID  -- Cancer Information Product   
							AND PRT.TermID IN (
									SELECT DrugID AS ObjectID 
									FROM 	vwDrug AS VD 
										INNER JOIN TermAlternateName AS AN
										ON VD.DrugID = AN.TermID 
									WHERE VD.[Name] = @Drug
										OR AN.[Name] = @Drug				
							)
						)
			END	
	
			IF( @SponsorOfTrial  IS NOT NULL) 
			BEGIN
				PRINT @SponsorOfTrial
				DELETE #tmpProtocolScope 
				WHERE ProtocolID NOT IN 
						(
						SELECT S.ProtocolID
						FROM 	ProtocolSponsor AS S
							INNER JOIN  (SELECT dbo.GetCancerGovTypeID( ObjectID ) AS SponsorID FROM dbo.udf_GetComaSeparatedIDs ( @SponsorOfTrial )) AS TempS
							ON S.SponsorID = TempS.SponsorID
						)
			END

			--GET Search Result AFTER other recordsets
			IF @NewOnly IS NOT NULL
			BEGIN
				SELECT 
					ProtocolID, 
					Title, 
					dbo.udf_GetProtocolAlternateIDs(ProtocolID) AS AlternateIDs --'TTTTTT-1' As AlternateIDs
				FROM  #tmpProtocolScope
				--WHERE ((NULLIF(ISNULL(@NewOnly, ''),'') IS NOT NULL) AND (IsNew = @NewOnly) OR ISNULL(@NewOnly, '') = '' )
				WHERE IsNew = @NewOnly
				ORDER BY Title
			END
			ELSE
			BEGIN
				SELECT 
					ProtocolID, 
					Title, 
					dbo.udf_GetProtocolAlternateIDs(ProtocolID) AS AlternateIDs --'TTTTTT-1' As AlternateIDs
				FROM  #tmpProtocolScope
				--WHERE ((NULLIF(ISNULL(@NewOnly, ''),'') IS NOT NULL) AND (IsNew = @NewOnly) OR ISNULL(@NewOnly, '') = '' )
				ORDER BY Title
			END
			
		END 

	PRINT '**** FINISH SEARCH ****'
	PRINT 'FREE USED RESOURCES'
	DROP TABLE #tmpProtocolScope
	DROP TABLE #tmpAlternateProtocolID

	RETURN 0 
END
GO
