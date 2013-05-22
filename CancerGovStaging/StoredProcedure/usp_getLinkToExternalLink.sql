if object_id('usp_getLinkToExternalLink') is not NULL
drop procedure dbo.usp_getLinkToExternalLink
GO
Create procedure dbo.usp_getLinkToExternalLink (@nciviewid uniqueidentifier)
as
BEGIN
	set nocount on

	select  v.NCIViewid, v.shortTitle as [Short Title], previewlive
	from
	(
	select  nciviewid, sum(previewlive) as previewLive
		from
		(
		select  distinct li.nciviewid, 1 as previewLive
		from dbo.listitem li inner join dbo.nciview v on v.nciviewid = li.nciviewid
		inner join dbo.prettyurl p on ( v.url like 'cancer.gov' + p.currenturl or v.url = p.currenturl)
		where p.nciviewid = @nciviewid and v.ncitemplateid is null
		union all
		select  distinct li.nciviewid,2 as previewLive
		from cancergov.dbo.listitem li inner join cancergov.dbo.nciview v on v.nciviewid = li.nciviewid
		inner join cancergov.dbo.prettyurl p on ( v.url like 'cancer.gov' + p.currenturl or v.url = p.currenturl)
		where p.nciviewid = @nciviewid and v.ncitemplateid is null
		) a
		group by nciviewid
	)b
		inner join dbo.nciview v on v.nciviewid = b.nciviewid
		order by 1

	

END 
GO

Grant execute on dbo.usp_getLinkToExternalLink to webadminUser_role
