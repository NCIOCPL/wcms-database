IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewLinkList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewLinkList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE usp_GetViewLinkList
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN

	SELECT ISNULL(vop.PropertyValue, v.Title) as Title,
		 v.URL + IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') as url,
		 v.IsLinkExternal as InternalOrExternal,
		 dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS PrettyUrl
	FROM ViewObjects vo
	LEFT OUTER JOIN ViewObjectProperty vop ON vo.NCIViewObjectID = vop.NCIViewObjectID AND vop.PropertyName = 'AlternateTitle'
	INNER JOIN NCIView v ON vo.ObjectID = v.NCIViewID
	WHERE vo.Type = 'LINK'
	AND vo.NCIViewID = @ViewId
	ORDER BY vo.Priority ASC

END
GO
GRANT EXECUTE ON [dbo].[usp_GetViewLinkList] TO [websiteuser_role]
GO
