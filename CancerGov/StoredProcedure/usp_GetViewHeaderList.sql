IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewHeaderList]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewHeaderList]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_GetViewHeaderList
	Object's type:	store proc
	Purpose:	Get NCIView's header information
	Author:		?
			10/26/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/	



CREATE PROCEDURE dbo.usp_GetViewHeaderList

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
		List.DescDisplay,	
		s.[Name] AS SectionName,
		s.SectionHomeViewId
	FROM 	NCIView v LEFT OUTER JOIN (ViewObjects vo INNER JOIN List ON vo.ObjectId = List.ListId) 
		ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection s 
		ON v.NCISectionId = s.NCISectionId
	WHERE vo.Type = 'HDRLIST' 
		AND v.NCIViewId = @ViewId
END

GO
GRANT EXECUTE ON [dbo].[usp_GetViewHeaderList] TO [websiteuser_role]
GO
