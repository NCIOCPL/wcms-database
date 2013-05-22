
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].usp_SearchContentKeyword') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].usp_SearchContentKeyword
GO

CREATE  PROCEDURE [dbo].usp_SearchContentKeyword
(
	@keyword varchar(1000),
	@isLive	bit,
	@PreviewURL		varchar(100)
)
AS
BEGIN
	BEGIN TRY
		If (@isLive =0)
		BEGIN
			SELECT Link='<a href=NCIViewRedirect.aspx?ReturnURL=&NCIViewID='+ CONVERT(varchar(38), v.NCIViewID) + '>Edit</a>',
			v.Title + '<br><a href="' + @PreviewURL  + v.url + IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') + '">' + v.url 
					+ IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') + '</a>' as 'Title/URL', 
			IsNull(p.currenturl, p.proposedURL) as prettyURL,  d.title as documentTitle, [type] as objectType
			from document d inner join viewobjects vo on vo.objectid = d.documentid
			inner join nciview v on v.nciviewid = vo.nciviewid
			left join prettyurl p on p.nciviewid = v.nciviewid and  p.isprimary =1 and p.isroot =1
			where data like '%'+@keyword+ '%' 
			order by v.title, type 
		END
		ELSE		  
		BEGIN
			SELECT Link='<a href=NCIViewRedirect.aspx?ReturnURL=&NCIViewID='+ CONVERT(varchar(38), v.NCIViewID) + '>Edit</a>',
			v.Title + '<br><a href="' + @PreviewURL  + v.url + IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') + '">' + v.url 
					+ IsNull(NullIf( '?'+IsNull(v.URLArguments,''),'?'),'') + '</a>' as 'Title/URL', 
			p.currenturl  as prettyURL, d.title as documentTitle, [type] as objectType
			from cancergov..document d inner join cancergov..viewobjects vo on vo.objectid = d.documentid
			inner join cancergov..nciview v on v.nciviewid = vo.nciviewid
			left join cancergov..prettyurl p on p.nciviewid = v.nciviewid and  p.isprimary =1 and p.isroot =1
			where data like '%'+@keyword+ '%' 
			order by v.title, type 
		END	
	

	END TRY

	BEGIN CATCH
		RETURN 10802
	END CATCH 
END
GO

GRANT EXECUTE ON [dbo].usp_SearchContentKeyword TO webAdminuser_role

GO

