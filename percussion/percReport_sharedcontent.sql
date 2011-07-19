if object_id('percReport_sharedcontent') is not null
drop procedure percReport_sharedcontent
go
create procedure dbo.percReport_sharedcontent(@contentid int = null)
as
BEGIN
	
		select o.dependentid, o.dependenttype, o.dependenttitle
			, o.ownertype
			, o.ownerid
			, 
			case 
			when ownertype like 'Nav%'
			then dbo.percreport_getitemfolderpath(o.ownerid)
			when  dbo.percReport_getpretty_url_name(o.ownerid) = '***' 
			then o.ownertitle
			when dbo.percreport_getitemfolderpath(o.ownerid)  like 'CancerGov/PrivateArchive%'  
				then NULL  
			ELSE dbo.percreport_getitemfolderpath(o.ownerid) + 
			 case when dbo.percReport_getpretty_url_name(o.ownerid) is null 
					then '' ELSE '/' +  dbo.percReport_getpretty_url_name(o.ownerid)	END 
				END as Parent
			from 
			(select distinct dependentid, dependenttype, c.title as dependenttitle,
				 o.contentid as ownerid , o.title as ownertitle, t.contenttypelabel as ownertype
				from dbo.percReport_viewshareddependent d
				inner join contentstatus c on c.contentid = d.dependentid
				inner join psx_objectrelationship r on r.dependent_id = d.dependentid
					and config_id <>3 
				inner join contentstatus o on o.contentid = r.owner_id and (r.owner_revision = -1 or r.owner_revision = c.public_revision)
				inner join contenttypes t on t.contenttypeid = o.contenttypeid
				where @contentid is null or d.dependentid = @contentid
			) o
		
		order by dependenttype, dependenttitle
END

GO

























