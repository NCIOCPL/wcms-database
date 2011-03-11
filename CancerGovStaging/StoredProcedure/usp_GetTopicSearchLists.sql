IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetTopicSearchLists]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetTopicSearchLists]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE usp_GetTopicSearchLists

	@viewid	uniqueidentifier

AS
BEGIN
	SELECT 	List.ListId, 
		List.ListName, 
		List.ListDesc, 
		List.Priority,
		List.DescDisplay,
		List.ReleaseDateDisplay,
		List.ReleaseDateDisplayLoc,
		List.NCIViewId,
		v.Title,
		dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS PrettyUrl,
		v.ShortTitle,
		v.Description,
		v.Url,
		v.UrlArguments
	FROM 	List 
	JOIN 	viewobjects o 
	ON 	List.ListId = o.objectid
	LEFT OUTER JOIN NCIView v 
		ON List.NCIViewId = v.NCIViewId
	WHERE 	o.nciviewid = @viewid
	AND	o.type='List'
	ORDER BY List.Priority ASC
END

GO
GRANT EXECUTE ON [dbo].[usp_GetTopicSearchLists] TO [websiteuser_role]
GO
