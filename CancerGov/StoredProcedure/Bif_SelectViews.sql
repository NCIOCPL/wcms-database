IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Bif_SelectViews]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[Bif_SelectViews]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE dbo.Bif_SelectViews
AS
	SET NOCOUNT ON;

SELECT NCIView.NCIViewID,
        Title = 
           CASE 
		WHEN type = 'SUMMARY_P' then (NCIView.Title + ' (Patient)' )
                WHEN type = 'SUMMARY_HP' then (NCIView.Title + ' (Health Professional)' )
                ELSE NCIView.Title
	   END,
	NCIView.ShortTitle,
	NCIView.Description,
	NCIView.NCITemplateID,
	NCIView.MetaDescription,
        NCIView.metakeyword,
	NCIView.ReleaseDate,
	NCIView.ExpirationDate,
	NCIView.PostedDate,
	NCIView.UpdateDate,
            nciview.revieweddate,
           SearchDate = case DisplayDateMode 
		when '1' then PostedDate
		when '5' then PostedDate
		else ReleaseDate
	end,
	NCIView.IsLinkExternal,
	NCIView.DisplayDateMode,
        NCIView.NCITemplateID,
	ViewObjects.ObjectID,
	ViewObjects.Type,
	ViewObjects.NCIViewObjectID,
        URL = 
           case
           when PrettyUrl.CurrentUrl is not null then 
              CASE
                WHEN type = 'SUMMARY_P' then (PrettyUrl.CurrentUrl + '/patient')
                WHEN type = 'SUMMARY_HP' then (PrettyUrl.CurrentUrl + '/healthprofessional')
		ELSE PrettyUrl.CurrentURL
              END
           else
              CASE 
		WHEN (NCIView.URLArguments is not null AND rtrim(ltrim(NCIView.URLArguments)) <> '') then (NCIView.URL + '?' + NCIView.URLArguments) 
                ELSE NCIView.URL
              END
           END,
           IsUrlPrettyUrl = 
	case
	WHEN PrettyUrl.CurrentUrl is not null then 1
             ELSE 0
          END,
	(select propertyvalue
	 from ViewProperty
	 where viewproperty.nciviewid = nciview.nciviewid
         and propertyname = 'SearchFilter'
        ) as SearchFilter,
        NCILanguage = case
	   when (select propertyvalue from
                 viewproperty
	         where viewproperty.nciviewid = nciview.nciviewid
                 and propertyname = 'IsSpanishContent'
                 ) = 'YES' THEN 'spanish'
            ELSE 'english'
            END,
        OtherLanguageUrl = CASE
	   	WHEN type = 'SUMMARY_P' then (select (p.currenturl + '/patient') from viewproperty vp
                      join prettyurl p
                      on vp.nciviewid = nciview.nciviewid
                      AND vp.propertyname = 'OtherLanguageViewID'
		      AND p.nciviewid = vp.propertyvalue
		      AND p.IsRoot = 1
		      AND p.IsPrimary = 1)
                WHEN type = 'SUMMARY_HP' then (select (p.currenturl + '/healthprofessional') from viewproperty vp
                      join prettyurl p
                      on vp.nciviewid = nciview.nciviewid
                      AND vp.propertyname = 'OtherLanguageViewID'
		      AND p.nciviewid = vp.propertyvalue
		      AND p.IsRoot = 1
		      AND p.IsPrimary = 1)
                ELSE (select p.currenturl from viewproperty vp
                      join prettyurl p
                      on vp.nciviewid = nciview.nciviewid
                      AND vp.propertyname = 'OtherLanguageViewID'
		      AND p.nciviewid = vp.propertyvalue
		      AND p.IsRoot = 1
		      AND p.IsPrimary = 1)
                END
FROM NCIView
	left JOIN ViewObjects
		ON NCIView.NCIViewID = ViewObjects.NCIViewID
	left JOIN PrettyURL
		ON NCIView.NCIViewID = PrettyURL.NCIViewID AND PrettyURL.IsPrimary = '1' AND PrettyURL.IsRoot = '1'
WHERE NCIView.NCIViewID not in (
	Select NCIViewID
	From
	ViewProperty
	Where
	PropertyName = 'RedirectURl'
)
AND
NCIView.NCIViewID not in (
	Select NCIViewID
	From
	ViewProperty
	Where
	PropertyName = 'DoNotIndexView'
	AND
	PropertyValue = 'true'
)
AND
NCIView.NCITemplateID is not null
AND
NCIView.NCITemplateID <> 'B1839996-C0F6-4D77-BD36-2AA0AD0B775E'
AND
NCIView.NciViewID not in (
select NCIObjectID from NCIObjects where ObjectType = 'LEFTNAV'
)
order by nciview.nciviewid

GO
GRANT EXECUTE ON [dbo].[Bif_SelectViews] TO [websiteuser_role]
GO
