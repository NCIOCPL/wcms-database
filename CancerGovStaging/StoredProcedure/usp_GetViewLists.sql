IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewLists]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewLists]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_GetViewLists
	Object's type:	store proc
	Purpose:	Get NCIView information
	Author:		?
			10/25/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/	


CREATE PROCEDURE dbo.usp_GetViewLists
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN
	SELECT v.Title, 
		v.ShortTitle, 
		v.Description, 
		v.Url, 
		v.UrlArguments, 
		v.MetaTitle, 
		v.MetaDescription, 
		v.MetaKeyword, 
		v.ReviewedDate,
		v.ChangeComments,
		List.ListId, 
		List.ListName, 
		List.ListDesc, 
		List.ParentListId, 
		List.Priority, 
		List.ReleaseDateDisplay,
		List.ReleaseDateDisplayLoc, 
		dbo.udf_GetViewObjectProperty(List.ListId, 'ShowListDescription') AS ShowListDescription,
		s.[Name] AS SectionName,
		s.SectionHomeViewId,
		s.TabImgName
	FROM 	NCIView v LEFT OUTER JOIN (ViewObjects vo INNER JOIN List ON vo.ObjectId = List.ListId) 
		ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection s 
		ON v.NCISectionId = s.NCISectionId
	WHERE vo.Type = 'LIST' 
		AND v.NCIViewId = @ViewId
	ORDER BY vo.Priority ASC
END

GO
GRANT EXECUTE ON [dbo].[usp_GetViewLists] TO [websiteuser_role]
GO
