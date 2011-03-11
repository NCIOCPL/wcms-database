drop function dbo.Mig_UrlViewidLookup
go
create function dbo.Mig_UrlViewidLookup(@url varchar(300))
returns @r table(viewid uniqueidentifier, [content type] varchar(200))
as
BEGIN
-- migmap page
	insert into @r
	select top 1 p.nciviewid, m.[page content type] as [content type]
	from prettyurl p inner join
		migmap m on m.nciviewid = p.nciviewid
		and p.isroot = 1
	where currenturl = @url 	and 
		m.[cancergov template] <> 'DigestPage'


	if exists (select * from @r)
		return
	ELSE
		--DigestPage
		insert into @r
		select top 1 p.nciviewid as viewid, 
			m.[page content type] as [content type]
			from prettyurl p inner join
				migmap m on m.nciviewid = p.nciviewid
			where currenturl = @url and 
				m.[cancergov template] = 'DigestPage'
				and p.objectid is null
		union all
		select top 1 p.objectid as viewid, 
			'nciGeneral' as [content type]
			from prettyurl p inner join
				migmap m on m.nciviewid = p.nciviewid and m.objectid = p.objectid
			where currenturl = @url and 
				m.[cancergov template] = 'DigestPage'
				and p.objectid is not null
		
		if exists (select * from @r)
			return
		ELSE
			--Microsite pages
				insert into @r
				select top 1 s.nciviewid , [content type]
				from microsites s 
					inner join prettyurl p on s.nciviewid = p.nciviewid
				where p.currenturl = @url and p.objectid is null
						and s.objecttype <> 'ncilist'
			
			if exists (select * from @r)
				return
				ELSE
						--multipage content
						insert into @r	
						select top 1 s.objectid , [content type]
						from microsites s 
							inner join prettyurl p 
							on s.nciviewid = p.nciviewid and s.objectid = p.objectid
						where p.currenturl = @url and 
								p.objectid is not null
								
	return
END
go