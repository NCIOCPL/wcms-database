IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetBestBetsByListId]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetBestBetsByListId]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_GetBestBetsByListId
	Object's type:	store proc
	Purpose:	To get bestbets by listid
	Author:		2/14/2004	Lijia

**********************************************************************************/

CREATE PROCEDURE usp_GetBestBetsByListId
	(
	@ListId	uniqueidentifier,
	@Where	varchar(1000) = NULL
	)
AS

DECLARE @SQL	varchar(1500)

BEGIN

	SELECT @Where = NULLIF(@Where, '')

	IF @Where IS NULL
	BEGIN
		SELECT 	bbc.CatName, 
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
		WHERE 	bbc.ListId = @ListId
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
WHERE 	bbc.ListId = ''' + CONVERT(char(36), @ListId) + ''' 
	AND (' + @WHERE + ') 
ORDER BY li.Priority'


	EXECUTE
		(
			@SQL
		)		
	END


END

GO
GRANT EXECUTE ON [dbo].[usp_GetBestBetsByListId] TO [websiteuser_role]
GO
