IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vw_SpanishSearchFilterView]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_SpanishSearchFilterView]
GO




/**********************************************************************************

	Object's name:	vw_SpanishSearchFilterView
	Object's type:	View
	Purpose:	Return NCIViews for Spanish search 
	Author:		Lijia Chu	08/13/04		
			Lijia		10/25/04  remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments
			Lijia		1/5/05    use number instead of string for DisplayDateMode

**********************************************************************************/

CREATE VIEW dbo.vw_SpanishSearchFilterView
AS

SELECT 
v.NCIViewID, 
v.NCITemplateID, 
v.NCISectionID, 
v.GroupID, 
v.Title, 
v.ShortTitle, 
v.Description,  
v.URL, 
v.URLArguments, 
v.MetaTitle,
v.MetaDescription, 
v.MetaKeyword, 
CONVERT(varchar, v.CreateDate, 101) AS CreateDate, 
CONVERT(varchar, v.ReleaseDate, 101) AS ReleaseDate,
CONVERT(varchar, v.ExpirationDate, 101) AS ExpirationDate, 
CONVERT(varchar, v.ReleaseDate, 108) AS ReleaseTime, 
v.Version, 
v.Status, 
v.IsOnProduction, 
v.IsMultiSourced, 
v.IsLinkExternal, 
v.SpiderDepth, 
CONVERT(varchar, v.UpdateDate, 101) AS UpdateDate, 
v.UpdateUserID, 
CONVERT(varchar, v.PostedDate, 101) AS PostedDate,
CONVERT(varchar, v.ReviewedDate, 101) AS ReviewedDate, 
v.ChangeComments, 
v.DisplayDateMode, 
s.Name AS SectionName, 
s.SectionHomeViewID, 
CONVERT(varchar, v.PostedDate, 108) AS PostedTime, 
s.TabImgName,
case DisplayDateMode 
	when '1' then PostedDate
	when '5' then PostedDate
	else ReleaseDate
end as 'Date',
vp.PropertyValue as SearchFilter,
(SELECT Top 1 CurrentUrl 
		FROM PrettyUrl 
		WHERE NCIViewId = v.NCIViewId AND IsPrimary = 1 AND IsRoot = 1  ) AS RootPrettyUrl
FROM dbo.NCIView v 
	LEFT OUTER JOIN dbo.NCISection s 
		ON v.NCISectionID = s.NCISectionID
	LEFT OUTER JOIN dbo.ViewProperty vp
		ON v.NCIViewID = vp.NCIViewID
		AND vp.PropertyName = 'SearchFilter'
Where 
	v.NCIViewID in (select NCIViewID
	from ViewProperty vp
	where 
	vp.PropertyName='IsSpanishContent' and
	vp.PropertyValue='Yes'
	)







GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([NCIViewID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([NCITemplateID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([NCISectionID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([GroupID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([Title]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([ShortTitle]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([Description]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([URL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([URLArguments]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([MetaTitle]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([MetaDescription]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([MetaKeyword]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([CreateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([ReleaseDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([ExpirationDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([ReleaseTime]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([Version]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([Status]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([IsOnProduction]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([IsMultiSourced]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([IsLinkExternal]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([SpiderDepth]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([UpdateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([UpdateUserID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([PostedDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([ReviewedDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([ChangeComments]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([DisplayDateMode]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([SectionName]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([SectionHomeViewID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([PostedTime]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([TabImgName]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([Date]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([SearchFilter]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_SpanishSearchFilterView] ([RootPrettyUrl]) TO [websiteuser_role]
GO
