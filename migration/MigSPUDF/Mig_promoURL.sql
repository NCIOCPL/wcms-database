drop procedure Mig_PromoURL
go
create procedure Mig_PromoURL
as
BEGIN

	select distinct u.nciviewid as viewid, m.[page content type]
	 , url as promo_url
	, url as promo_url_name
	from migurl u inner join migmap m on u.nciviewid = m.nciviewid
	where isroot =1 and isprimary =0
	union
	select nciviewid, 'nciGeneral', [current url] , [current url] from ncigeneral
	where [pretty url] in

	(
	'/clinicaltrials/search/printresults',
	'/clinicaltrials/search/view',
	'/clinicaltrials/search/results',
	'/cancertopics/genetics/directory',
	'/cancertopics/genetics/directory/results',
	'/cancertopics/genetics/directory/view',
	'/search/results')
	order by 1,2
		
END
Go
