IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCIView]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_GetNCIView
	Object's type:	store proc
	Purpose:	Get NCIView information
	Author:		?
			10/26/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments

**********************************************************************************/

CREATE PROCEDURE dbo.usp_GetNCIView
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN

	SELECT 
		v.NCIViewID,
		v.NCITemplateID,
		v.NCISectionID,
		v.GroupID,
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
		CONVERT(varchar,v.CreateDate,101) AS CreateDate,
		CONVERT(varchar,v.ReleaseDate,101) AS ReleaseDate,
		CONVERT(varchar,v.ExpirationDate,101) AS ExpirationDate,
		CONVERT(varchar,v.ReleaseDate, 108) AS ReleaseTime,
		v.Version,
		v.Status,
		v.IsOnProduction,
		v.IsMultiSourced,
		v.IsLinkExternal,
		v.SpiderDepth,
		CONVERT(varchar,v.UpdateDate,101) AS UpdateDate,
		v.UpdateUserID,
		CONVERT(varchar,v.PostedDate,101) AS PostedDate,
		v.DisplayDateMode,
		s.[Name] As SectionName,
		s.SectionHomeViewId,
		CONVERT(varchar,v.PostedDate,108) AS PostedTime,
		s.TabImgName,
		dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS RootPrettyUrl		
	FROM 	NCIView v LEFT OUTER JOIN NCISection s 
		ON v.NCISectionId = s.NCISectionId
	WHERE v.NCIViewID = @ViewId

END


GO
GRANT EXECUTE ON [dbo].[usp_GetNCIView] TO [websiteuser_role]
GO
