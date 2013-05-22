IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Template_Newsletter_GetViewNLList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Template_Newsletter_GetViewNLList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_Template_Newsletter_GetViewNLList (
	@ListID	uniqueidentifier
)
AS
BEGIN
	SELECT v.NCIViewID, 
		nli.Title, 
		nli.ShortTitle, 
		nli.[Description],
		v.URL,
		v.URLArguments,
		IsFeatured
	FROM NLListItem nli, NCIView v
	WHERE nli.ListID = @ListID
	  AND nli.NCIViewID = v.NCIViewID
	ORDER BY Priority
END
GO
