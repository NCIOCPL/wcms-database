IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetChildLists]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetChildLists]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE usp_GetChildLists

	@ParentListId	uniqueidentifier

AS
BEGIN
	SELECT List.ListId, 
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
	FROM List LEFT OUTER JOIN NCIView v ON List.NCIViewId = v.NCIViewId
	WHERE List.ParentListId = @ParentListId 
	ORDER BY List.Priority ASC
END
GO
GRANT EXECUTE ON [dbo].[usp_GetChildLists] TO [websiteuser_role]
GO
