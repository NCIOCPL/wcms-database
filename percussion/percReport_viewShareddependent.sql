if object_id('percReport_viewShareddependent') is not null
	 drop view dbo.percReport_viewSharedDependent
go
create view dbo.percReport_viewSharedDependent
as
select distinct b.contentid as dependentid, b.contenttypelabel as dependenttype
						from
							(
								select contentid , contenttypelabel , count(*)  as count
										from
										(select distinct
										c.contentid
										, t.contenttypelabel
										, o.contentid as owner
										from contentstatus c 
										inner join contenttypes t on c.contenttypeid = t.contenttypeid
										inner join dbo.psx_objectrelationship r on r.dependent_id = c.contentid and r.config_id <>3 
										inner join dbo.contentstatus o on o.contentid = r.owner_id 
												and (  r.owner_revision = o.public_revision
														or r.owner_revision = o.currentrevision
														or r.owner_revision = o.editrevision) 
										where contenttypename  in
										(select contenttypename from percReport_contenttype 
												where type = 'supporting'											

																	)	
											--and contentid = 							
											)a
								group by contentid, contenttypelabel
								having count(*) > 1
							)b