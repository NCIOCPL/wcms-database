IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetListItems]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetListItems]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_GetListItems
	Object's type:	store proc
	Purpose:	Get NCIView information by ListId
	Author:		?
			10/26/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/

CREATE PROCEDURE dbo.usp_GetListItems

	@ListId		uniqueidentifier

AS
BEGIN
	SELECT v.NCIViewId, 
		v.Title, 
		v.ShortTitle, 
		v.Description, 
		v.URL, 
		v.URLArguments, 
		v.IsMultiSourced, 
		v.IsLinkExternal,
		v.ReviewedDate,
		v.ChangeComments, 
		CONVERT(varchar, v.ReleaseDate, 101) AS ReleaseDate,
		CONVERT(varchar, v.UpdateDate, 101) AS UpdateDate,
		CONVERT(varchar, v.PostedDate, 101) AS PostedDate,
		v.DisplayDateMode,
		s.[Name] AS SectionName,
		li.Priority, 
		li.IsFeatured,
		dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS PrettyUrl

	FROM ListItem li INNER JOIN NCIView v ON li.NCIViewId = v.NCIViewId
		INNER JOIN NCISection s ON v.NCISectionID = s.NCISectionID		

	WHERE li.ListId = @ListId

	ORDER BY li.Priority ASC, v.ShortTitle ASC
END

GO
GRANT EXECUTE ON [dbo].[usp_GetListItems] TO [websiteuser_role]
GO
