update p set press_release_type = p.subheader
from contentstatus c inner join CT_CGVPRESSRELEASE p
on c.contentid = p.contentid
where c.contentcreateddate > '2011-6-13' and subheader is not null


update p set  p.subheader = NULL
from contentstatus c inner join CT_CGVPRESSRELEASE p
on c.contentid = p.contentid
where c.contentcreateddate > '2011-6-13' and subheader is not null


--
--select c.contentid,c.contentcreateddate, p.subheader, press_release_type
--from contentstatus c inner join CT_CGVPRESSRELEASE p
--on c.contentid = p.contentid
--and c.currentrevision = p.revisionid
--where c.contentcreateddate > '2011-6-13'
--order by c.contentid
--
--
--select press_release_type, count(*)
--from CT_CGVPRESSRELEASE 
--group by press_release_type
--order by 1





