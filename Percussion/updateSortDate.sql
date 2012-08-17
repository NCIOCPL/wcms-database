use percussion
go

insert into GLOQUERYSET_GLOQUERYSET(contentid, revisionid, sort_date)
select c.contentid, c.currentrevision, gc.date_first_published
from contentstatus c 
inner join CGVCONTENTDATES_CGVCONTENTDATES1 gc 
on gc.contentid = c.contentid and gc.revisionid = c.currentrevision
inner join contenttypes t on t.contenttypeid = c.contenttypeid
where contenttypename in
( 'cgvpressrelease', 'cgvExternalNewsLink')
and
c.contentid not in 
(select contentid from GLOQUERYSET_GLOQUERYSET)
and date_first_published is not null