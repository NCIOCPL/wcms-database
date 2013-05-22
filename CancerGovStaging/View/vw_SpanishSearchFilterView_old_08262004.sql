IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vw_SpanishSearchFilterView_old_08262004]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_SpanishSearchFilterView_old_08262004]
GO

--*************************************************************************
-- Create Object
--*************************************************************************

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
v.HTMLAddendum, 
v.URL, 
v.URLArguments, 
v.OldURL, 
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
v.DisplayDateMode, 
s.Name AS SectionName, 
s.SectionHomeViewID, 
CONVERT(varchar, v.PostedDate, 108) AS PostedTime, 
s.TabImgName,
case DisplayDateMode 
	when 'posted' then PostedDate
	else ReleaseDate
end as 'Date',

--dbo.udf_GetViewPrettyUrl(v.NCIViewID) AS RootPrettyUrl
vp.PropertyValue as SearchFilter
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
