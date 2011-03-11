IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_TermDD_GetMatchingTerms]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_TermDD_GetMatchingTerms]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:  Stored Procedure dbo.usp_TermDD_GetMatchingTerms    Script Date: 6/29/2005 2:37:41 PM ******/




/**********************************************************************************

	Object's name:	usp_TermDD_GetMatchingTerms
	Object's type:	store proc
	Purpose:	need stored proc that can search for all drug terms that match 'Term%':
			by search word that matches against prefered and/or all othernames.  

			Search returns a list of:
			1) CDRID
			2) prefered name
			3) othernames that match
			4) definition HTML

	Author:		5/10/2005	Chen Ling
	Change History:
	5/10/2005	Chen Ling	adds 'OtherNamesP' field to return OtherNames or not
	5/13/2005	Chen Ling	added paging
	6/3/2005 	Zhuomin		Remove udf
	6/28/2005	Chen Ling	gets US brand name as well as preferred name for alphalist search
**********************************************************************************/	

CREATE PROCEDURE dbo.usp_TermDD_GetMatchingTerms
	(
	@Match	nvarchar(2000) = '%',
	@PageSize	int = 10000,
	@CurPage	int = 1,
	@OtherNamesP char(1) = 'Y', -- 'Y' / 'N' ... if 'Y' then return matching othernames, 'N' returns preferred names and US brand names only (no other name matching on search)
	@NumMatches	int OUTPUT
	)
AS
BEGIN
	DECLARE @Start	int,
		@End int

	SELECT @Start = (@CurPage - 1) * @PageSize + 1
	SELECT @End = @CurPage * @PageSize

	CREATE TABLE #results (
		ResultID int identity(1,1),
		TermID int,
		PreferredName nvarchar(2200),
		OtherName nvarchar(2200),
		DefinitionHTML nvarchar(max)
	)

	CREATE TABLE #sort (
		SortID	int identity(1,1),
		ResultID int
	)

	IF (@OtherNamesP = 'N')
	BEGIN
		INSERT INTO #results (TermID, PreferredName, DefinitionHTML)
		SELECT TermID,
			PreferredName,
			DefinitionHTML
		FROM vwTermDrugDictionary
		WHERE PreferredName LIKE @Match + '%'
		ORDER BY PreferredName

		INSERT INTO #results (TermID, PreferredName, DefinitionHTML)
		SELECT ton.TermID, 
			ton.OtherName,
			'(Other name for: ' + tdd.PreferredName + ')'
		FROM vwTermDrugDictionary  tdd, TermOtherName ton
		WHERE tdd.TermID = ton.TermID
		AND ton.OtherNameType = 'US brand name'
		AND OtherName LIKE @Match + '%'
		ORDER BY PreferredName

		INSERT INTO #sort (ResultID)
		SELECT ResultID
		FROM #results
		ORDER BY CAST(LOWER(PreferredName) AS BINARY)

		SELECT @NumMatches = COUNT(ResultID) FROM #sort

		SELECT r.TermID, PreferredName, OtherName, DefinitionHTML
		FROM #results r
			INNER JOIN #sort s on r.ResultID = s.ResultID
		WHERE s.SortID >= @Start
		AND s.SortID <= @End
		ORDER BY s.SortID
	END
	ELSE
	BEGIN
		INSERT INTO #results (TermID, PreferredName, OtherName, DefinitionHTML)
		
		SELECT TermID,
			--dbo.udf_TermDD_FormatDrugMatch(PreferredName, @Match) AS PreferredName,
			PreferredName,
			NULL as OtherName,
			DefinitionHTML
		FROM vwTermDrugDictionary
		WHERE PreferredName LIKE @Match + '%'
		
		UNION 
		
		SELECT ton.TermID,
			--dbo.udf_TermDD_FormatDrugMatch(PreferredName, @Match) AS PreferredName,
			PreferredName,
			--dbo.udf_TermDD_FormatDrugMatch(ton.OtherName, @Match) AS OtherName,
			ton.OtherName,
			DefinitionHTML
		FROM vwTermDrugDictionary t
			INNER JOIN TermOtherName ton on t.TermID = ton.TermID
		WHERE ton.OtherName LIKE @Match + '%'
			AND ISNULL(ton.OtherName, '') <> ''
	

		INSERT INTO #sort (ResultID)
		SELECT TermID
		FROM Terminology
		WHERE TermID IN (
			SELECT DISTINCT TermID
			FROM #results
		)
		ORDER BY CAST(LOWER(PreferredName) AS BINARY)

		SELECT @NumMatches = COUNT(ResultID) FROM #sort

		SELECT r.TermID, PreferredName, OtherName, DefinitionHTML
		FROM #results r
			INNER JOIN #sort s on r.TermID = s.ResultID
		WHERE s.SortID >= @Start
		AND s.SortID <= @End
		ORDER BY s.SortID, CAST(LOWER(OtherName) AS BINARY)
	END

	DROP TABLE #sort
	DROP TABLE #results
END

GO
GRANT EXECUTE ON [dbo].[usp_TermDD_GetMatchingTerms] TO [websiteuser_role]
GO
