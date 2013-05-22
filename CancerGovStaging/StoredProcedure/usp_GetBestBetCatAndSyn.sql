IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetBestBetCatAndSyn]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetBestBetCatAndSyn]
GO

/**********************************************************************************

	Object's name:	usp_GetBestBetCatAndSyn
	Object's type:	Stored Procedure
	Purpose:	Gets a join of the Categories and synonyms
	Change History:	11/04/2004	Lijia add ChangeComments
					01/08/2008	Bryan -- Added in IsExactMatch
**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetBestBetCatAndSyn
AS
	SET NOCOUNT ON;

	--There is the possiblility of duplicate records if a synname == its catname,
	--however the admin tool should have a constrain to make sure that does not 
	--happen

	--Get Categories
	SELECT
		CategoryID,
		CatName,
		weight as CategoryWeight,
		catName as Keywords,
		0 as IsNegated,
		listID,
		ChangeComments, --Is this nessasary?
		case when IsSpanish = 1 then 'Spanish' else 'English' end as Language,
		IsExactMatch
	FROM BestBetCategories
	UNION
	SELECT
		bbc.CategoryID,
		bbc.CatName,
		bbc.Weight as CategoryWeight,
		bbs.SynName as Keywords,
		bbs.IsNegated,
		bbc.ListID,
		bbc.ChangeComments,
		case when bbc.IsSpanish = 1 then 'Spanish' else 'English' end as Language,
		bbs.IsExactMatch
	FROM BestBetSynonyms bbs
	JOIN BestBetCategories bbc
	ON bbs.CategoryID = bbc.CategoryID
	ORDER BY ListID

GO
GRANT EXECUTE ON [dbo].[usp_GetBestBetCatAndSyn] TO [websiteuser_role]
GO

