IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].usp_searchViewWithTag') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_searchViewWithTag
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_searchViewWithTag  
* Owner:Jhe 
* Purpose: For admin side Script Date: 12/28/2009  ******/


CREATE PROCEDURE [dbo].usp_searchViewWithTag
(
	@Type varchar(20),
	@AdminURL varchar(200),
	@ListDrugInfoCG varchar(max) =''
)
AS
BEGIN	

	if (lower(@Type) = 'untagged')
	BEGIN
		SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
				case isnull(p.currentURL, '') WHEN  ''
				then N.Title + '<br><a href="' +@AdminURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
				Else  N.Title + '<br><a href="'+@AdminURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
				End as 'Title/URL',  
				'Short Title'=N.ShortTitle, 
				'Owner Group'=G.GroupName, 
				'Section' = S.[name] ,
				'Updated'=Convert(varchar,N.UpdateDate,102), 
				'Expires'=Convert(varchar,N.ExpirationDate,102),V.PropertyValue as 'Tag'
				FROM NCIView  AS N  
					inner join ViewProperty V on N.NCIViewID = V.NCIViewID 
					inner join Groups G on N.GroupID=G.GroupID
					inner join  NCISection S ON N.NCISectionID = S.NCISectionID
					left outer join prettyurl p
						on n.nciviewid = p.nciviewid and 
						p.IsRoot=1 and p.IsPrimary=1 
				where  n.ncitemplateid is not null and V.PropertyName='Tag' and V.PropertyValue=@Type   
					and	(n.ncitemplateid not in (select ncitemplateid from ncitemplate
											where name in ('Benchmark', 'NEWSLETTER', 'summary', 'AutomaticRSSFeed', 'ManualRSSFeed')) 
							and (n.ncisectionid <> 'F2901263-4A99-44A8-A1DA-92B16E173E86' or n.nciviewid in
					( 
							SELECT Item
							FROM udf_ListToGuid(@ListDrugInfoCG, ',')
					)) )
		Union
		SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
				case isnull(p.currentURL, '') WHEN  ''
				then N.Title + '<br><a href="' +@AdminURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
				Else  N.Title + '<br><a href="'+@AdminURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
				End as 'Title/URL',  
				'Short Title'=N.ShortTitle, 
				'Owner Group'=G.GroupName, 
				'Section' = S.[name] ,
				'Updated'=Convert(varchar,N.UpdateDate,102), 
				'Expires'=Convert(varchar,N.ExpirationDate,102),'' as 'Tag'
				FROM NCIView  AS N  
					inner join Groups G on N.GroupID=G.GroupID
					inner join  NCISection S ON N.NCISectionID = S.NCISectionID
					left outer join prettyurl p
						on n.nciviewid = p.nciviewid and 
						p.IsRoot=1 and p.IsPrimary=1 
				where  n.ncitemplateid is not null and 
					N.NCIViewID not in ( select distinct nciviewid from  viewproperty where propertyname  ='tag')
					and	(n.ncitemplateid not in (select ncitemplateid from ncitemplate
											where name in ('Benchmark', 'NEWSLETTER', 'summary', 'AutomaticRSSFeed', 'ManualRSSFeed')) 
							and (n.ncisectionid <> 'F2901263-4A99-44A8-A1DA-92B16E173E86' or n.nciviewid in
					( 
							SELECT Item
							FROM udf_ListToGuid(@ListDrugInfoCG, ',')
					)) )
		order by 'Title/URL'	 
	END
	ELSE if (lower(@Type) = 'tagged')
	BEGIN
		SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
				case isnull(p.currentURL, '') WHEN  ''
				then N.Title + '<br><a href="' +@AdminURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
				Else  N.Title + '<br><a href="'+@AdminURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
				End as 'Title/URL',  
				'Short Title'=N.ShortTitle, 
				'Owner Group'=G.GroupName, 
				'Section' = S.[name] ,
				'Updated'=Convert(varchar,N.UpdateDate,102), 
				'Expires'=Convert(varchar,N.ExpirationDate,102),V.PropertyValue as 'Tag'
				FROM NCIView  AS N  
					inner join ViewProperty V on N.NCIViewID = V.NCIViewID 
					inner join Groups G on N.GroupID=G.GroupID
					inner join  NCISection S ON N.NCISectionID = S.NCISectionID
					left outer join prettyurl p
						on n.nciviewid = p.nciviewid and 
						p.IsRoot=1 and p.IsPrimary=1 
				where  n.ncitemplateid is not null and V.PropertyName='Tag' and V.PropertyValue <> 'untagged'   
					and	(n.ncitemplateid not in (select ncitemplateid from ncitemplate
											where name in ('Benchmark', 'NEWSLETTER', 'summary', 'AutomaticRSSFeed', 'ManualRSSFeed')) 
							and (n.ncisectionid <> 'F2901263-4A99-44A8-A1DA-92B16E173E86' or n.nciviewid in
					( 
							SELECT Item
							FROM udf_ListToGuid(@ListDrugInfoCG, ',')
					)) )
		order by  'Title/URL'	 
	END
	ELSE if (lower(@Type) = 'redirecturl')
	BEGIN
		SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
				case isnull(p.currentURL, '') WHEN  ''
				then N.Title + '<br><a href="' +@AdminURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
				Else  N.Title + '<br><a href="'+@AdminURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
				End as 'Title/URL',  
				'Short Title'=N.ShortTitle, 
				'Owner Group'=G.GroupName, 
				'Section' = S.[name] ,
				'Updated'=Convert(varchar,N.UpdateDate,102), 
				'Expires'=Convert(varchar,N.ExpirationDate,102),V.PropertyValue as 'Tag'
				FROM NCIView  AS N  
					inner join ViewProperty V on N.NCIViewID = V.NCIViewID 
					inner join Groups G on N.GroupID=G.GroupID
					inner join  NCISection S ON N.NCISectionID = S.NCISectionID
					left outer join prettyurl p
						on n.nciviewid = p.nciviewid and 
						p.IsRoot=1 and p.IsPrimary=1 
				where  n.ncitemplateid is not null and V.PropertyName='RedirectURL'
					and	(n.ncitemplateid not in (select ncitemplateid from ncitemplate
											where name in ('Benchmark', 'NEWSLETTER', 'summary', 'AutomaticRSSFeed', 'ManualRSSFeed')) 
							and (n.ncisectionid <> 'F2901263-4A99-44A8-A1DA-92B16E173E86' or n.nciviewid in
					( 
							SELECT Item
							FROM udf_ListToGuid(@ListDrugInfoCG, ',')
					)) )
		order by  'Title/URL'	 
	END
END

GO
GRANT EXECUTE ON [dbo].usp_searchViewWithTag TO [webadminuser_role]
GO
