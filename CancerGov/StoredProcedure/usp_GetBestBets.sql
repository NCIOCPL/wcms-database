IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetBestBets]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetBestBets]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
CREATE PROCEDURE usp_GetBestBets
	(
	@CategoryId	uniqueidentifier,
	@Where	varchar(1000) = NULL
	)
AS
BEGIN

	EXECUTE CancerGovStaging.dbo.usp_GetBestBets @CategoryId, @Where

END
GO
*/


/*
8/14/2002 	Alex/Jay	Point ListItem table to CancerGovStaging Database
*/

CREATE PROCEDURE usp_GetBestBets
	(
	@CategoryId	uniqueidentifier,
	@Where	varchar(1000) = NULL
	)
AS

DECLARE @SQL	varchar(1500)

BEGIN

	SELECT @Where = NULLIF(@Where, '')

	IF @Where IS NULL
	BEGIN
		SELECT bbc.CatName, 
			v.NCIViewID, 
			v.Title, 
			v.ShortTitle, 
			v.[Description], 
			v.URL, 
			v.URLArguments, 
			dbo.udf_GetViewPrettyUrl(v.NCIViewID) AS PrettyUrl, 
			v.IsLinkExternal
		FROM 	CancerGovStaging..BestBetCategories bbc 
			INNER JOIN CancerGovStaging..ListItem li 
				ON bbc.ListId = li.ListId
			INNER JOIN NCIView v 
				ON li.NCIViewID = v.NCIViewID
		WHERE 	bbc.CategoryId = @CategoryId
		ORDER BY li.Priority
	END
	ELSE
	BEGIN
		SELECT @SQL = 
'SELECT bbc.CatName, 
	v.NCIViewID, 
	v.Title, 
	v.ShortTitle, 
	v.[Description], 
	v.URL, 
	v.URLArguments, 
	dbo.udf_GetViewPrettyUrl(v.NCIViewID) AS PrettyUrl, 
	v.IsLinkExternal
FROM 	CancerGovStaging..BestBetCategories bbc 
	INNER JOIN CancerGovStaging..ListItem li 
		ON bbc.ListId = li.ListId
	INNER JOIN NCIView v 
		ON li.NCIViewID = v.NCIViewID
WHERE 	bbc.CategoryId = ''' + CONVERT(char(36), @CategoryId) + ''' 
	AND (' + @WHERE + ') 
ORDER BY li.Priority'
		EXECUTE
		(
			@SQL
		)		
	END

/*
	SELECT @Where = NULLIF(@Where, '')

	IF @Where IS NULL
	BEGIN
		SELECT bbc.CatName, v.NCIViewID, v.Title, v.ShortTitle, v.[Description], v.URL, v.URLArguments, dbo.udf_GetViewPrettyUrl(v.NCIViewID) AS PrettyUrl, v.IsLinkExternal
		FROM CancerGovStaging..BestBetCategories bbc INNER JOIN ListItem li ON bbc.ListId = li.ListId
			INNER JOIN NCIView v ON li.NCIViewID = v.NCIViewID
		WHERE bbc.CategoryId = @CategoryId
		ORDER BY li.Priority
	END
	ELSE
	BEGIN
		SELECT @SQL = 'SELECT bbc.CatName, v.NCIViewID, v.Title, v.ShortTitle, v.[Description], v.URL, v.URLArguments, dbo.udf_GetViewPrettyUrl(v.NCIViewID) AS PrettyUrl, v.IsLinkExternal
					FROM CancerGovStaging..BestBetCategories bbc INNER JOIN ListItem li ON bbc.ListId = li.ListId
					INNER JOIN NCIView v ON li.NCIViewID = v.NCIViewID
					WHERE bbc.CategoryId = ''' + CONVERT(char(36), @CategoryId) + ''' AND (' + @WHERE + ') ORDER BY li.Priority'
		EXECUTE
		(
			@SQL
		)		
	END
*/
END
GO
GRANT EXECUTE ON [dbo].[usp_GetBestBets] TO [websiteuser_role]
GO
