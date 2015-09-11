if object_id('percReport_TileAging') is not null
	drop procedure dbo.percReport_TileAging
go
create procedure dbo.percReport_TileAging (@starttime datetime , @endtime datetime, @contentid int = NULL)
as
BEGIN
		select b.contentid, b.title
			, owner_id, ownertype
		, case when ownertype like '%Carousel%' then ownertitle else
		 dbo.percReport_getitemfolderpath(b.owner_id)   END as werePublished
		, appeartime
	    , dbo.percReport_getRemoveDate(contentid, owner_id, b.owner_revision, @starttime,@endtime) as removetime
				from (
						select contentid, title, owner_id
								, ownertype, ownertitle
								, min(owner_revision) as owner_revision, min(appeartime) as appeartime
								from
								(			
										select 
										c1.contentid, c1.title
										, r.owner_id 
										, c.title as ownertitle
										, r.owner_revision
										, h.eventtime as appeartime
										,t.contenttypelabel as ownertype
										from contentstatus c 
										inner join contenttypes t on c.contenttypeid = t.contenttypeid
										inner join psx_objectrelationship r on r.owner_id = c.contentid 
										inner join contentstatushistory h 
										on h.contentid = c.contentid and r.owner_revision = h.revisionid
										inner join contentstatus c1 on c1.contentid = r.dependent_id
										inner join contentstatushistory dh on dh.contentid = c1.contentid and dh.statename = 'public' and dh.eventtime < = h.eventtime
										where h.statename = 'public'  
										and r.dependent_id in 
											(select contentid from contentstatus c inner join contenttypes t on c.contenttypeid = t.contenttypeid 
													where contenttypename = 'nciTile')

										and h.eventtime < = @endtime
									)a
								group by contentid, title, owner_id, ownertype , ownertitle
					) b
					where @contentid is null or contentid = @contentid
					order by b.title, owner_id

END
		GO

