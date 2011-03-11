IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewDocument]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewDocument]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/**********************************************************************************

	Object's name:	usp_GetViewDocument
	Object's type:	store proc
	Purpose:	Get NCIView's documents information
	Author:		?
			10/26/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/	



CREATE PROCEDURE dbo.usp_GetViewDocument
	(
	@ViewId	uniqueidentifier,
	@DocumentId	uniqueidentifier = NULL
	)
AS
BEGIN
	IF (@DocumentId IS NULL)
		BEGIN
			SELECT TOP 1 v.Title, 
				v.ShortTitle, 
				v.[Description], 
				v.URL, 
				v.URLArguments, 
				dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS PrettyUrl, 
				v.MetaTitle, 
				v.MetaKeyword, 
				v.MetaDescription, 
				v.IsLinkExternal, 
				v.NCITemplateID, 
				v.ReviewedDate,
				v.ChangeComments, 
				vo.Priority, 
				d.DocumentId, 
				d.Title AS DocTitle, 
				d.ShortTitle AS DocShortTitle, 
				d.Data, 
				d.TOC, 
				CONVERT(varchar,v.CreateDate,101) AS CreateDate, 
				CONVERT(varchar, v.ReleaseDate, 101) AS ReleaseDate, 
				s.[Name] AS SectionName, 
				s.SectionHomeViewId, 
				CONVERT(varchar, v.PostedDate, 101) AS PostedDate, 
				v.DisplayDateMode, 
				s.TabImgName
			FROM NCIView v LEFT OUTER JOIN (ViewObjects vo INNER JOIN Document d ON vo.ObjectId = d.DocumentId) ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection s ON v.NCISectionId = s.NCISectionId
			WHERE v.NCIViewId = @ViewId AND vo.Type = 'DOCUMENT'
			ORDER BY vo.Priority
		END
	ELSE
		BEGIN
			SELECT	v.Title, 
				v.ShortTitle, 
				v.[Description], 
				v.URL, 
				v.URLArguments, 
				dbo.udf_GetViewObjectPrettyUrl(v.NCIViewId, d.DocumentId) AS PrettyUrl, 
				v.MetaTitle, 
				v.MetaKeyword, 
				v.MetaDescription, 
				v.IsLinkExternal, 
				v.NCITemplateID, 
				v.ReviewedDate,
				v.ChangeComments, 
				vo.Priority, 
				d.DocumentId, 
				d.Title AS DocTitle, 
				d.ShortTitle AS DocShortTitle, 
				d.Data, 
				d.TOC, 
				CONVERT(varchar,v.CreateDate,101) AS CreateDate, 
				CONVERT(varchar, v.ReleaseDate, 101) AS ReleaseDate, 
				s.[Name] AS SectionName, 
				s.SectionHomeViewId, 
				CONVERT(varchar, v.PostedDate, 101) AS PostedDate, 
				v.DisplayDateMode, 
				s.TabImgName
			FROM NCIView v LEFT OUTER JOIN (ViewObjects vo INNER JOIN Document d ON vo.ObjectId = d.DocumentId)  ON v.NCIViewId = vo.NCIViewId LEFT OUTER JOIN NCISection s ON v.NCISectionId = s.NCISectionId
			WHERE v.NCIViewId = @ViewId AND d.DocumentId = @DocumentId AND vo.Type = 'DOCUMENT'
		END
END

GO
GRANT EXECUTE ON [dbo].[usp_GetViewDocument] TO [websiteuser_role]
GO
