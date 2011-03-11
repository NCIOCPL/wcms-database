IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_Template_Newsletter_GetViewNLSections]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_Template_Newsletter_GetViewNLSections]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_Template_Newsletter_GetViewNLSections (
	@viewID	uniqueidentifier
)
AS
BEGIN
	SELECT NLSectionID,
		Title,
		ShortTitle,
		[Description],
		HTMLBody,
		PlainBody
	FROM NLSection nls, ViewObjects vo
	WHERE vo.NCIViewID = @viewID
	AND vo.ObjectID = nls.NLSectionID
	AND vo.Type = 'NLSection '
	ORDER BY vo.Priority
END
GO
GRANT EXECUTE ON [dbo].[usp_Template_Newsletter_GetViewNLSections] TO [websiteuser_role]
GO
