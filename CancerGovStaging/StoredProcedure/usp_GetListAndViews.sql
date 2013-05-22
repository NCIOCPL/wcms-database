IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetListAndViews]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetListAndViews]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetListAndViews
	Object's type:	Stored procedure
	Purpose:	Get List, view and ViewProperty by ListID
	
	Change History:
	09/01/2004 	Bryan Pizzillo 	Script Created
	09/01/2004 	Lijia Chu	use 'join' instead of 'in'
	10/26/2004	Lijia	Remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments		


**********************************************************************************/
CREATE PROCEDURE dbo.usp_GetListAndViews

	@ListId		uniqueidentifier

AS

--Fetch the row of list information out of the db
SELECT	*
FROM	List
WHERE 	ListId = @ListId

--Fetch all the "listitems" out, a.k.a. views
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
		dbo.udf_GetViewPrettyUrl(v.NCIViewId) AS RootPrettyUrl,
		ListItem.Priority,
		ListItem.IsFeatured
				
FROM	NCIView v
LEFT OUTER JOIN NCISection s
  ON 	v.NCISectionId = s.NCISectionId 
LEFT OUTER JOIN ListItem 
  ON 	ListItem.NCIViewID = v.NCIViewID
WHERE 	ListItem.ListID = @listid
ORDER By ListItem.Priority



--Fetch all of the view properties associated with the "listitems"	
SELECT	p.NCIViewID, 
	PropertyName, 
	PropertyValue
FROM 	ViewProperty p 
JOIN	ListItem l 
  ON	p.NCIViewID=l.NCIViewID
WHERE 	l.ListID = @listid
	
	


GO
GRANT EXECUTE ON [dbo].[usp_GetListAndViews] TO [websiteuser_role]
GO
