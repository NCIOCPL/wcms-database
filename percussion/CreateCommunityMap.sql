if object_id('communityMap') is not null
	drop table communityMap

create table dbo.communityMap (communityid int, mappedCommunityid int)

insert into communityMap
select distinct m1.communityid, m.COMMUNITYID
from rxcommunity m inner join rxcommunity m1 on (m.name like m1.name + '%' or m1.name like m.name + '%')
