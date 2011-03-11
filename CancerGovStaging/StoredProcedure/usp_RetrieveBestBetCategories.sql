IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveBestBetCategories]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveBestBetCategories]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************************

	Object's name:	usp_RetrieveBestBetCategories 
	Object's type:	Stored Procedure
	Purpose:	Update Categories
	Change History:	7/16/2003	Jay He	
			11/04/2004	Lijia add ChangeComments

**********************************************************************************/
CREATE PROCEDURE dbo.usp_RetrieveBestBetCategories
AS
	SELECT 	CategoryID, 
		CatName, 
		IsSpanish,
		CASE 		IsSpanish
			WHEN 1 THEN 'S'
			Else	''
		END
		as 'Lang',
		Status, 
		Weight, 
		'Edit List' AS EditList, 
		'../Object/StagingListItem.aspx?ListID='+ CONVERT(varchar(38), ListID) + '&ReturnURL='  AS ListURL,
		ChangeComments
	FROM 	BestBetCategories 
	ORDER BY CatName


GO
GRANT EXECUTE ON [dbo].[usp_RetrieveBestBetCategories] TO [webadminuser_role]
GO
