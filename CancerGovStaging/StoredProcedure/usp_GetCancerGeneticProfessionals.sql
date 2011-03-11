IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetCancerGeneticProfessionals]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetCancerGeneticProfessionals]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*	Stored procedure used as Search in Cancer Genetics Services Directory 
*
*	Objects Used:
*	CancerGov..ProtocolRelatedTerm - table
*
*	Change History:
*	?/?/2001 	Alex Pidlisnyy	Script Created
*	5/29/2002 	Alex/Stas	Fix bug: Change INNER JOIN to LEFT OUTER when 
*					@CancerFamily AND @CancerType IS NULL
*	5/30/2002 	Alex/Stas	Fix bug: narrow search by location (state-country-city)
*/


CREATE PROCEDURE [dbo].[usp_GetCancerGeneticProfessionals]
	(
	@CancerType		varchar(2000) = null,
	@CancerFamily	varchar(2000) = null,	-- *
	@City			varchar(100) = null,	-- *
	@StateID		varchar(2000) = null,	-- *
	@CountryID		varchar(2000) = null,	-- *
	@Lastname		varchar(100) = null 	-- *
	)

AS
BEGIN
	
	/*
	SELECT @Lastname = NULLIF(@Lastname, '')
	SELECT @CountryID = NULLIF(@CountryID, '') 		
	SELECT @City = NULLIF(@City, '') 		
	SELECT @CancerFamily = NULLIF(@CancerFamily, '') 		
	SELECT @CancerType = NULLIF(@CancerType, '') 		
	SELECT @StateID = NULLIF(@CancerType, '') 		
	*/

	IF  (@CancerFamily IS NULL) AND (@CancerType IS NULL)
	BEGIN
		IF ( @CountryID IS NULL ) AND (@StateID IS NULL) AND (@City IS NULL)
		BEGIN
			SELECT DISTINCT [ID] as PersonID,
				FirstName + ' ' + LastName + ' ' + ISNULL(Suffix, '') AS FullName,
				Degree,
				LastName
			FROM 	GeneticsProfessional AS GP 
				--INNER JOIN GenProfPracticeLocations AS PL	
				LEFT OUTER JOIN GenProfPracticeLocations AS PL	
				ON 	GP.[ID] = PL.GenProfID
					AND (((@CountryID IS NOT NULL) AND (PL.Country IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CountryID)))) OR @CountryID IS NULL) 
					AND (((@StateID IS NOT NULL) AND (UPPER(LTRIM(RTRIM(PL.State))) IN (SELECT UPPER(LTRIM(RTRIM(ObjectID))) FROM dbo.udf_GetComaSeparatedIDs ( @StateID)))) OR @StateID IS NULL) 
					AND ((@City IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@City))) = UPPER(LTRIM(RTRIM(PL.City)))) OR @City IS NULL) 
			WHERE ((@Lastname IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@Lastname))) = UPPER(LTRIM(RTRIM(LastName)))) OR @Lastname IS NULL) 
			ORDER BY LastName
		END
		ELSE BEGIN
			SELECT DISTINCT [ID] as PersonID,
				FirstName + ' ' + LastName + ' ' + ISNULL(Suffix, '') AS FullName,
				Degree,
				LastName
			FROM 	GeneticsProfessional AS GP 
				INNER JOIN GenProfPracticeLocations AS PL	
				--LEFT OUTER JOIN GenProfPracticeLocations AS PL	
				ON 	GP.[ID] = PL.GenProfID
					AND (((@CountryID IS NOT NULL) AND (PL.Country IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CountryID)))) OR @CountryID IS NULL) 
					AND (((@StateID IS NOT NULL) AND (UPPER(LTRIM(RTRIM(PL.State))) IN (SELECT UPPER(LTRIM(RTRIM(ObjectID))) FROM dbo.udf_GetComaSeparatedIDs ( @StateID)))) OR @StateID IS NULL) 
					AND ((@City IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@City))) = UPPER(LTRIM(RTRIM(PL.City)))) OR @City IS NULL) 
			WHERE ((@Lastname IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@Lastname))) = UPPER(LTRIM(RTRIM(LastName)))) OR @Lastname IS NULL) 
			ORDER BY LastName
		END
	END
	ELSE 
	IF (@CancerFamily IS NOT NULL) AND (@CancerType IS NULL)
	BEGIN
		SELECT DISTINCT [ID] as PersonID,
			FirstName + ' ' + LastName + ' ' + ISNULL(Suffix, '') AS FullName,
			Degree,
			LastName
		FROM 	GeneticsProfessional AS GP INNER JOIN GenProfPracticeLocations AS PL	
			ON 	GP.[ID] = PL.GenProfID
				AND (((@CountryID IS NOT NULL) AND (PL.Country IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CountryID)))) OR @CountryID IS NULL) 
				AND (((@StateID IS NOT NULL) AND (UPPER(LTRIM(RTRIM(PL.State))) IN (SELECT UPPER(LTRIM(RTRIM(ObjectID))) FROM dbo.udf_GetComaSeparatedIDs ( @StateID)))) OR @StateID IS NULL) 
				AND ((@City IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@City))) = UPPER(LTRIM(RTRIM(PL.City)))) OR @City IS NULL) 
		INNER JOIN GenProfAreasOfSpecialization AS AOS
		ON 	GP.[ID] = AOS.GenProfID
			AND AOS.Syndrome IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CancerFamily))
		WHERE ((@Lastname IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@Lastname))) = UPPER(LTRIM(RTRIM(LastName)))) OR @Lastname IS NULL) 
		ORDER BY LastName
	END
	ELSE 
	IF (@CancerFamily IS NULL) AND (@CancerType IS NOT NULL)
	BEGIN

		SELECT DISTINCT [ID] as PersonID,
			FirstName + ' ' + LastName + ' ' + ISNULL(Suffix, '') AS FullName,
			Degree,
			LastName
		FROM 	GeneticsProfessional AS GP INNER JOIN GenProfPracticeLocations AS PL	
			ON 	GP.[ID] = PL.GenProfID
				AND (((@CountryID IS NOT NULL) AND (PL.Country IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CountryID)))) OR @CountryID IS NULL) 
				AND (((@StateID IS NOT NULL) AND (UPPER(LTRIM(RTRIM(PL.State))) IN (SELECT UPPER(LTRIM(RTRIM(ObjectID))) FROM dbo.udf_GetComaSeparatedIDs ( @StateID)))) OR @StateID IS NULL) 
				AND ((@City IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@City))) = UPPER(LTRIM(RTRIM(PL.City)))) OR @City IS NULL) 
		INNER JOIN GenProfAreasOfSpecialization AS AOS
		ON 	GP.[ID] = AOS.GenProfID
			AND 	 AOS.CancerTypeSiteID IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CancerType))
		WHERE ((@Lastname IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@Lastname))) = UPPER(LTRIM(RTRIM(LastName)))) OR @Lastname IS NULL) 
		ORDER BY LastName
	END
	ELSE 
	IF (@CancerFamily IS NOT NULL) AND (@CancerType IS NOT NULL)
	BEGIN
		SELECT DISTINCT [ID] as PersonID,
			FirstName + ' ' + LastName + ' ' + ISNULL(Suffix, '') AS FullName,
			Degree,
			LastName
		FROM 	GeneticsProfessional AS GP INNER JOIN GenProfPracticeLocations AS PL	
			ON 	GP.[ID] = PL.GenProfID
				AND (((@CountryID IS NOT NULL) AND (PL.Country IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CountryID)))) OR @CountryID IS NULL) 
				AND (((@StateID IS NOT NULL) AND (UPPER(LTRIM(RTRIM(PL.State))) IN (SELECT UPPER(LTRIM(RTRIM(ObjectID))) FROM dbo.udf_GetComaSeparatedIDs ( @StateID)))) OR @StateID IS NULL) 
				AND ((@City IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@City))) = UPPER(LTRIM(RTRIM(PL.City)))) OR @City IS NULL) 
		INNER JOIN GenProfAreasOfSpecialization AS AOS
		ON 	GP.[ID] = AOS.GenProfID
			AND 
			(
				(AOS.Syndrome IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CancerFamily)))
				OR
				( AOS.CancerTypeSiteID IN (SELECT ObjectID FROM dbo.udf_GetComaSeparatedIDs ( @CancerType)))
			)
		WHERE ((@Lastname IS NOT NULL) AND (UPPER(LTRIM(RTRIM(@Lastname))) = UPPER(LTRIM(RTRIM(LastName)))) OR @Lastname IS NULL) 
		ORDER BY LastName
	END



END
GO
