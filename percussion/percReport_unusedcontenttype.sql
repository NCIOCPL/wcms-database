
if object_id('percReport_unusedcontent') is not null
drop procedure percReport_unusedcontent
go
create procedure dbo.percReport_unusedcontent(@contentid int = null)
as
BEGIN
			select contentid
			, title
			, contenttypelabel
			, s.statename
			, dbo.percReport_getitemfolderpath(contentid) as path
			, contentlastmodifieddate
			from 
					(
					select c.contentid, c.title, t.contenttypelabel
					,dbo.percReport_getsite(contentid) as site, contentstateid,workflowappid
					, contentlastmodifieddate
					from contentstatus c inner join contenttypes t on c.contenttypeid = t.contenttypeid
					where 
					not exists (
								select * from psx_objectrelationship r inner join dbo.contentstatus c1
												on c1.contentid = r.owner_id and
												(	r.owner_revision = c1.public_revision
													or
													r.owner_revision = c1.currentrevision
													or 
													r.owner_revision = c1.editrevision
													
												)
								where r.dependent_id = c.contentid
										
									and config_id <> 3
							)

									and contenttypename in
									(
									select contenttypename from dbo.percReport_contenttype
									where type = 'supporting'

									)
					)a
			inner join WORKFLOWAPPS w on w.workflowappid = a.workflowappid
			inner join states s on a.contentstateid = s.stateid and s.workflowappid = w.workflowappid
			where site = 'cancergov' and (@contentid is null or contentid = @contentid)
			--order by contenttypename, title

			union 
			select  p.contentid, p.promo_url
			, 'secondary URL' as contenttypelabel
			, s.statename
			, dbo.percReport_getitemfolderpath(p.contentid)
			, contentlastmodifieddate
			from 
			 contentstatus c inner join dbo.CT_CGVPROMOURL1 p on p.contentid = c.contentid and c.public_revision = p.revisionid
			inner join WORKFLOWAPPS w on w.workflowappid = c.workflowappid
			inner join states s on c.contentstateid = s.stateid and s.workflowappid = w.workflowappid
			where 
			not exists 
				(select * from dbo.psx_objectrelationship r 
					where  r.owner_id = c.contentid and 
						(r.owner_revision = -1 or r.owner_revision = coalesce( c.public_revision, c.currentrevision)
						)
					and config_id = 1
				)
			and (@contentid is null or c.contentid = @contentid)
			and dbo.percReport_getsite(c.contentid) = 'cancergov'
			order by contenttypelabel, title
END























