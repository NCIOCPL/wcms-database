if object_id('gaoEndeca_donotindexFiles') is not null
drop procedure dbo.gaoEndeca_donotindexFiles
go
Create procedure dbo.gaoEndeca_donotindexFiles
as
BEGIN
update p set do_not_index = 1
from contentstatus c inner join RXS_CT_SHAREDBINARY b on c.contentid = b.contentid
inner join CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 P ON P.CONTENTID = c.contentid
and c.currentrevision = b.revisionid
where contenttypeid = 463 and b.item_ext in ( '.ics', '.epub','.mobi', '.css')
and (do_not_index = 0 or do_not_index is null)
END
GO