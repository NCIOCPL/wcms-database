IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].usp_searchViewWithInvalidXHTML') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].usp_searchViewWithInvalidXHTML
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_searchViewWithInvalidXHTML  
* Owner:Jhe 
* Purpose: For admin side Script Date: 12/28/2009  ******/


CREATE PROCEDURE [dbo].usp_searchViewWithInvalidXHTML
(
	@ProdURL varchar(200),
	@ListDrugInfoCG varchar(max) ='',
	@DTDLocation nvarchar(300) = N'C:\\Temp\\xhtml1-transitional.dtd'
)
AS
BEGIN	
	if (@ListDrugInfoCG is null or @ListDrugInfoCG ='') -- No CancerGov only DrugInfoSummary
	BEGIN 

		SELECT N.NCIViewID, N.url AS 'URL',N.NCISectionID,
				case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'  
									when 'http://' then N.Title + '<br><a href="'+N.url +'">' + N.url+ '</a>'
				end as 'Title/URL',  
				'Short Title'=N.ShortTitle, 
				N.Description, 
				'Owner Group'=G.GroupName, 
				'Section' = S.[name] ,
				'Updated'=Convert(varchar,N.UpdateDate,102), 
				'Expires'=Convert(varchar,N.ExpirationDate,102) 
				FROM NCIView  AS N 
					inner join Groups G on N.GroupID=G.GroupID
					inner join  NCISection S ON N.NCISectionID = S.NCISectionID
					inner join dbo.invalidXHTMLView  I on N.NCIViewID = I.NCIViewID
				where n.ncitemplateid is null and  n.status='Edit' and DateDiff(day, N.UpdateDate, getdate()) >14
		union
		SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
				case isnull(p.currentURL, '') WHEN  ''
				then N.Title + '<br><a href="' +@ProdURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
				Else  N.Title + '<br><a href="'+@ProdURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
				End as 'Title/URL',  
				'Short Title'=N.ShortTitle, 
				N.Description, 
				'Owner Group'=G.GroupName, 
				'Section' = S.[name] ,
				'Updated'=Convert(varchar,N.UpdateDate,102), 
				'Expires'=Convert(varchar,N.ExpirationDate,102)
				FROM NCIView  AS N  
					inner join Groups G on N.GroupID=G.GroupID
					inner join  NCISection S ON N.NCISectionID = S.NCISectionID
					inner join dbo.invalidXHTMLView  I on N.NCIViewID = I.NCIViewID
					left outer join prettyurl p
						on n.nciviewid = p.nciviewid and 
						p.IsRoot=1 and p.IsPrimary=1 
				where  n.ncitemplateid is not null  AND n.status='Edit' and DateDiff(day, N.UpdateDate, getdate()) >14
		order by  'Updated'	
	END
	ELSE
	BEGIN
		--Additional Drug Info Summaries only on CancerGov needs to be checked for XHTML validation

		declare @view table (nciviewid uniqueidentifier )

			
			insert into @view
			select vo.nciviewid
						from  dbo.viewobjects  vo with (nolock) inner join dbo.document   d with (nolock)
								on d.documentid = vo.objectid
						where  vo.nciviewid  in
							( 
									SELECT Item
									FROM udf_ListToGuid(@ListDrugInfoCG, ',')
							)
							and  type not in ('SEARCH','VirSearch')
								and 
									(dbo.udf_IsValidXHTML(data,@DTDLocation) = 0 
									or dbo.udf_IsValidXHTML(description,@DTDLocation) = 0 
									or dbo.udf_IsValidXHTML(toc,@DTDLocation) = 0 
									)	



			insert into @view
			select vo.nciviewid
					from  dbo.viewobjects vo with (nolock) inner join dbo.externalobject e with (nolock) on e.externalobjectid = vo.objectid
					where 	vo.nciviewid  in
							( 
									SELECT Item
									FROM udf_ListToGuid(@ListDrugInfoCG, ',')
							)
							and 
								(dbo.udf_IsValidXHTML(text,@DTDLocation) = 0 
								or dbo.udf_IsValidXHTML(description,@DTDLocation) = 0 
								)
		

			insert into @view
			select nciviewid from dbo.nciview  with (nolock)
			where nciviewid  in
							( 
									SELECT Item
									FROM udf_ListToGuid(@ListDrugInfoCG, ',')
							)
							and  
						 dbo.udf_IsValidXHTML(description,@DTDLocation) = 0 


			insert into @view
			select vo.nciviewid from 
				viewobjects vo with (nolock) inner join list l with (nolock) on l.listid = vo.objectid
			where  vo.nciviewid  in
							( 
									SELECT Item
									FROM udf_ListToGuid(@ListDrugInfoCG, ',')
							)
							and 
							l.listDesc is not null and dbo.udf_IsValidXHTML(listDesc,@DTDLocation) = 0 

			--select * from @view

	SELECT N.NCIViewID, N.url AS 'URL',N.NCISectionID,
			case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'  
								when 'http://' then N.Title + '<br><a href="'+N.url +'">' + N.url+ '</a>'
			end as 'Title/URL',  
			'Short Title'=N.ShortTitle, 
			N.Description, 
			'Owner Group'=G.GroupName, 
			'Section' = S.[name] ,
			'Updated'=Convert(varchar,N.UpdateDate,102), 
			'Expires'=Convert(varchar,N.ExpirationDate,102) 
			FROM NCIView  AS N 
				inner join Groups G on N.GroupID=G.GroupID
				inner join  NCISection S ON N.NCISectionID = S.NCISectionID
			where N.NCIViewID in (select distinct nciviewid from @view) and 
				n.ncitemplateid is null and  n.status='Edit' and DateDiff(day, N.UpdateDate, getdate()) >14
	union
	SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
			case isnull(p.currentURL, '') WHEN  ''
			then N.Title + '<br><a href="' +@ProdURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
			Else  N.Title + '<br><a href="'+@ProdURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
			End as 'Title/URL',  
			'Short Title'=N.ShortTitle, 
			N.Description, 
			'Owner Group'=G.GroupName, 
			'Section' = S.[name] ,
			'Updated'=Convert(varchar,N.UpdateDate,102), 
			'Expires'=Convert(varchar,N.ExpirationDate,102)
			FROM NCIView  N
				inner join Groups G on N.GroupID=G.GroupID
				inner join  NCISection S ON N.NCISectionID = S.NCISectionID
				left outer join prettyurl p
					on n.nciviewid = p.nciviewid and 
					p.IsRoot=1 and p.IsPrimary=1 
			where N.NCIViewID in (select distinct nciviewid from @view) and
				 n.ncitemplateid is not null  AND n.status='Edit' and DateDiff(day, N.UpdateDate, getdate()) >14
	Union
	SELECT N.NCIViewID, N.url AS 'URL',N.NCISectionID,
			case LEFT(N.url , 7) when 'https:/'  then N.Title + '<br><a href="' + N.url+ '">' + N.url+ '</a>'  
								when 'http://' then N.Title + '<br><a href="'+N.url +'">' + N.url+ '</a>'
			end as 'Title/URL',  
			'Short Title'=N.ShortTitle, 
			N.Description, 
			'Owner Group'=G.GroupName, 
			'Section' = S.[name] ,
			'Updated'=Convert(varchar,N.UpdateDate,102), 
			'Expires'=Convert(varchar,N.ExpirationDate,102) 
			FROM NCIView  AS N 
				inner join Groups G on N.GroupID=G.GroupID
				inner join  NCISection S ON N.NCISectionID = S.NCISectionID
				inner join dbo.invalidXHTMLView  I on N.NCIViewID = I.NCIViewID
			where n.ncitemplateid is null and  n.status='Edit' and DateDiff(day, N.UpdateDate, getdate()) >14
	union
	SELECT N.NCIViewID, P.CurrentURL AS 'URL',N.NCISectionID,
			case isnull(p.currentURL, '') WHEN  ''
			then N.Title + '<br><a href="' +@ProdURL+ N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '">' + N.url + IsNull(NullIf( '?'+IsNull(N.URLArguments,''),'?'),'') + '</a>' 
			Else  N.Title + '<br><a href="'+@ProdURL+  P.CurrentURL  + '">' + P.CurrentURL  + '</a>' 
			End as 'Title/URL',  
			'Short Title'=N.ShortTitle, 
			N.Description, 
			'Owner Group'=G.GroupName, 
			'Section' = S.[name] ,
			'Updated'=Convert(varchar,N.UpdateDate,102), 
			'Expires'=Convert(varchar,N.ExpirationDate,102)
			FROM NCIView  AS N  
				inner join Groups G on N.GroupID=G.GroupID
				inner join  NCISection S ON N.NCISectionID = S.NCISectionID
				inner join dbo.invalidXHTMLView  I on N.NCIViewID = I.NCIViewID
				left outer join prettyurl p
					on n.nciviewid = p.nciviewid and 
					p.IsRoot=1 and p.IsPrimary=1 
			where  n.ncitemplateid is not null  AND n.status='Edit' and DateDiff(day, N.UpdateDate, getdate()) >14
    order by  'Updated'	 

	END
END


GO
GRANT EXECUTE ON [dbo].usp_searchViewWithInvalidXHTML TO [webadminuser_role]
GO
