IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Template_Newsletter_GetViewNLLists]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Template_Newsletter_GetViewNLLists]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_Template_Newsletter_GetViewNLLists (
	@viewID	uniqueidentifier
)
AS
BEGIN
	SELECT ListID, 
		ListName, 
		ListDesc, 
		DescDisplay, 
		ReleaseDateDisplay, 
		ReleaseDateDisplayLoc
	FROM ViewObjects vo, List l
	WHERE vo.NCIViewID = @viewID
	AND vo.ObjectID = l.ListID
	AND vo.Type = 'NLList '
	ORDER BY vo.Priority
END
GO
GRANT EXECUTE ON [dbo].[usp_Template_Newsletter_GetViewNLLists] TO [websiteuser_role]
GO
