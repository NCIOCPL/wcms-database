IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetCancerGeneticProfessionals]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetCancerGeneticProfessionals]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
* 	Stored procedure used as Search in Cancer Genetics Services Directory 
*
*	Objects Used:
*
*	Change History:
*	8/9/2002 	Alex Pidlisnyy	Script Created
*	12/5/2002	Chen Ling	Munged script for speed
*	12/8/2002	Chen Ling	Updated script to use IDs instead of names for CancerType and CancerFamily
*
*	To Do List:
*
*/

CREATE PROCEDURE [dbo].[usp_GetCancerGeneticProfessionals]
	(
	@CancerType	varchar(2000) = null,	-- Coma separated list of "CancerType: CancerSite" 	
	@CancerFamily	varchar(2000) = null,	-- Coma separated list 
	@City		varchar(100) = null,	-- *
	@StateID	varchar(2000) = null,	-- Coma separated list of States short names
	@CountryID	varchar(2000) = null,	-- Coma separated list of Countries
	@Lastname	varchar(100) = null 	-- *
	)

AS
BEGIN

	PRINT 'Restricting by LastName'
	CREATE TABLE #by_name (GenProfID int)
	IF @Lastname IS NULL
		BEGIN
			INSERT INTO #by_name (GenProfID)
			SELECT GenProfID
			FROM GenProf
		END
	ELSE
		BEGIN
			INSERT INTO #by_name (GenProfID)
			SELECT DISTINCT GenProfID
			FROM GenProf
			WHERE UPPER(LTRIM(RTRIM(@Lastname))) = UPPER(LTRIM(RTRIM(LastName)))
		END

	PRINT 'Restricting by City'
	CREATE TABLE #by_city (GenProfID int)
	IF @City IS NULL
		BEGIN
			INSERT INTO #by_city (GenProfID)
			SELECT GenProfID
			FROM GenProf
			WHERE GenProfID IN (SELECT GenProfID FROM #by_name)
		END
	ELSE
		BEGIN
			INSERT INTO #by_city (GenProfID)
			SELECT DISTINCT GenProfID
			FROM GenProfPracticeLocation
			WHERE UPPER(LTRIM(RTRIM(@City))) = UPPER(LTRIM(RTRIM(City)))
			AND GenProfID IN (SELECT GenProfID FROM #by_name)
		END

	PRINT 'Restricting by State'
	CREATE TABLE #by_state (GenProfID int)
	IF @StateID IS NULL
		BEGIN
			INSERT INTO #by_state (GenProfID)
			SELECT GenProfID
			FROM GenProf
			WHERE GenProfID IN (SELECT GenProfID FROM #by_city)
		END
	ELSE
		BEGIN
			INSERT INTO #by_state (GenProfID)
			SELECT DISTINCT GenProfID
			FROM GenProfPracticeLocation
			WHERE UPPER(LTRIM(RTRIM(State))) IN (
				SELECT UPPER(LTRIM(RTRIM(ObjectID)))
				FROM dbo.udf_GetComaSeparatedIDs ( @StateID )
			)
			AND GenProfID IN (SELECT GenProfID FROM #by_city)
		END

	PRINT 'Restricting by Country'
	CREATE TABLE #by_country (GenProfID int)
	IF @CountryID IS NULL
		BEGIN
			INSERT INTO #by_country (GenProfID)
			SELECT GenProfID
			FROM GenProf
			WHERE GenProfID IN (SELECT GenProfID FROM #by_state)
		END
	ELSE
		BEGIN
			INSERT INTO #by_country (GenProfID)
			SELECT DISTINCT GenProfID
			FROM GenProfPracticeLocation
			WHERE UPPER(LTRIM(RTRIM(Country))) IN (
				SELECT UPPER(LTRIM(RTRIM(ObjectID)))
				FROM dbo.udf_GetComaSeparatedIDs ( @CountryID )
			)
			AND GenProfID IN (SELECT GenProfID FROM #by_state)
		END

	PRINT 'Restricting by CancerFamily'
	CREATE TABLE #by_cancerfamily (GenProfID int)
	IF @CancerFamily IS NULL
		BEGIN
			INSERT INTO #by_cancerfamily (GenProfID)
			SELECT GenProfID
			FROM GenProf
			WHERE GenProfID IN (SELECT GenProfID FROM #by_country)
		END
	ELSE
		BEGIN
			INSERT INTO #by_cancerfamily (GenProfID)
			SELECT DISTINCT GenProfID
			FROM GenProfFamilyCancerSyndrome fcs, GenProfFamilyCancerSyndromeList fcsl
			WHERE fcsl.FamilyCancerSyndromeListID IN (
				SELECT ObjectID
				FROM dbo.udf_GetComaSeparatedIDs ( @CancerFamily )
			)
			AND fcs.FamilyCancerSyndrome = fcsl.FamilyCancerSyndrome
			AND GenProfID IN (SELECT GenProfID FROM #by_country)
		END

	PRINT 'Restricting by CancerType'
	CREATE TABLE #by_cancertype (GenProfID int)
	IF @CancerType IS NULL
		BEGIN
			INSERT INTO #by_cancertype (GenProfID)
			SELECT GenProfID
			FROM GenProf
			WHERE GenProfID IN (SELECT GenProfID FROM #by_cancerfamily)
		END
	ELSE
		BEGIN
			INSERT INTO #by_cancertype (GenProfID)
			SELECT DISTINCT GenProfID
			FROM GenProfTypeOfCancer
			WHERE CancerTypeSiteID IN ( SELECT ObjectID 
				FROM dbo.udf_GetComaSeparatedIDs ( @CancerType ))
			AND GenProfID IN (SELECT GenProfID FROM #by_cancerfamily)
		END

	PRINT 'Retrieving result set'
	SELECT GP.GenProfID AS PersonID,
		ISNULL( FirstName, '') + ' ' + ISNULL( LastName, '') + ' ' + ISNULL( Suffix, '') AS FullName,
		ISNULL( Degree, '') AS 'Degree',
		LastName
	FROM GenProf AS GP, #by_cancertype AS FinalSet
	WHERE GP.GenProfID = FinalSet.GenProfID
	ORDER BY LastName
END
GO
GRANT EXECUTE ON [dbo].[usp_GetCancerGeneticProfessionals] TO [websiteuser_role]
GO
