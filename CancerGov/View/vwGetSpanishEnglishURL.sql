IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwGetSpanishEnglishURL]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwGetSpanishEnglishURL]
GO
create view vwGetSpanishEnglishURL as

select 'http://www.cancer.gov'+ P.currentURL  as SpanishURL, 'http://www.cancer.gov' + PE.currentURL  as EnglishURL
from
	(select nciviewid as spanishViewid , 
		propertyValue as EnglishViewID  from dbo.ViewProperty where nciviewid in
			(select distinct nciviewid from dbo.viewobjects 
				where nciviewid in
					(select  v.nciviewid  from dbo.viewproperty  p 
						inner join dbo.nciview v on p.nciviewid = v.nciviewid 
						inner join dbo.ncitemplate t on t.ncitemplateid = v.ncitemplateid
						inner join dbo.prettyURL U on U.nciviewid =  v.nciviewid
						where propertyname = 'IsSpanishContent' and  propertyvalue = 'YES'
							and U.isRoot = 1 and U.isPrimary = 1 
					) 
					and type in ('Summary_P', 'summary_HP' )
				)
			and propertyName =  'otherLanguageViewid'
	) SE
	inner join dbo.prettyURL p on p.nciviewid = SE.spanishViewid
	inner join dbo.prettyURL pE on pE.nciviewid = SE.EnglishViewid
	inner join dbo.Nciview v on v.nciviewid = SE.spanishViewid
	inner join dbo.Nciview vE on vE.nciviewid = SE.EnglishViewid
where  P.isRoot = 1 and P.isPrimary = 1  and PE.isRoot = 1 and PE.isPrimary = 1 



GO
