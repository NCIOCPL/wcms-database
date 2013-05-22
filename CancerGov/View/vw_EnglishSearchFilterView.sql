IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vw_EnglishSearchFilterView]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_EnglishSearchFilterView]
GO




/**********************************************************************************

	Object's name:	vw_EnglishSearchFilterView
	Object's type:	View
	Purpose:	Return NCIViews for English search 
	Author:		Lijia Chu	08/13/04		
			Lijia		10/25/04  remove OLDURL,HTMLAddendum and add ReviewedDate, ChangeComments
			Lijia		1/5/05    use number instead of string for DisplayDateMode

**********************************************************************************/

CREATE VIEW dbo.vw_EnglishSearchFilterView
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
	v.NCIViewID NOT in (select NCIViewID
	from ViewProperty vp
	where 
	vp.PropertyName='IsSpanishContent' and
	vp.PropertyValue='Yes'
	)







GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([NCIViewID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([NCITemplateID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([NCISectionID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([GroupID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([Title]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([ShortTitle]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([Description]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([URL]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([URLArguments]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([MetaTitle]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([MetaDescription]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([MetaKeyword]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([CreateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([ReleaseDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([ExpirationDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([ReleaseTime]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([Version]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([Status]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([IsOnProduction]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([IsMultiSourced]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([IsLinkExternal]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([SpiderDepth]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([UpdateDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([UpdateUserID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([PostedDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([ReviewedDate]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([ChangeComments]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([DisplayDateMode]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([SectionName]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([SectionHomeViewID]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([PostedTime]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([TabImgName]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([Date]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([SearchFilter]) TO [websiteuser_role]
GO
GRANT SELECT ON [dbo].[vw_EnglishSearchFilterView] ([RootPrettyUrl]) TO [websiteuser_role]
GO
