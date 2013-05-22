if object_id('percReport_getRemoveDate')  is not null
	drop function dbo.percReport_getRemoveDate
go
create function dbo.percReport_getRemoveDate 
(@contentid int, @owner_id int, @revision int, @starttime datetime, @endtime datetime)
returns datetime
as
BEGIN
	declare @removedate datetime
	select @removedate =  h.eventtime
	from contentstatushistory h
	where contentid = @owner_id 
	and eventtime > =@starttime
	and eventtime < = @endtime
	and h.revisionid > @revision
	and not exists 
		(select * from psx_objectrelationship r 
			where  r.owner_id = @owner_id and owner_revision = h.revisionid
				and r.dependent_id = @contentid
		)
	and statename = 'public'
	order by h.eventtime

	return @removedate

END