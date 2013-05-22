IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCIViewObjects]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCIViewObjects]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_GetNCIViewObjects
	Object's type:	store proc
	Purpose:	Get NCIView's objects information
	Author:		?
			10/26/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/

CREATE PROCEDURE dbo.usp_GetNCIViewObjects
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN
	SELECT v.NCIViewId, 
		v.Title, 
		v.ShortTitle, 
		v.[Description], 
		v.URL, 
		v.URLArguments, 
		v.MetaTitle, 
		v.MetaDescription, 
		v.MetaKeyword, 
		v.ReviewedDate,
		v.ChangeComments, 
		vo.ObjectId, 
		vo.Type,
		s.[Name] AS SectionName,
		s.SectionHomeViewId,
		s.TabImgName
	FROM 	NCIView v INNER JOIN ViewObjects vo 
		ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection s 
		ON v.NCISectionId = s.NCISectionId
	WHERE v.NCIViewId = @ViewId
	ORDER BY vo.Priority
END

GO
GRANT EXECUTE ON [dbo].[usp_GetNCIViewObjects] TO [websiteuser_role]
GO
