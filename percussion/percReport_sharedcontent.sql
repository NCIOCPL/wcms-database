if object_id('percReport_sharedcontent') is not null
drop procedure percReport_sharedcontent
go
create procedure dbo.percReport_sharedcontent(@contentid int = null)
as
BEGIN
	
		select o.dependentid, o.dependenttype, o.dependenttitle
			, o.ownertype
			, o.ownerid
			,d.folderpath as dependentItempath
			, 
			case 
			when ownertype like 'Nav%'
				then p.folderpath 
			when  dbo.percReport_getpretty_url_name(o.ownerid) = '***' 
			then o.ownertitle
			when p.folderpath   like 'CancerGov/PrivateArchive%'  
				then NULL  
			ELSE p.folderpath  + 
			 case when dbo.percReport_getpretty_url_name(o.ownerid) is null 
					then '' ELSE '/' +  dbo.percReport_getpretty_url_name(o.ownerid)	END 
				END as Parent
				, p.folderpath as parentItemPath
			from 
			(select distinct dependentid, dependenttype, c.title as dependenttitle,
				 o.contentid as ownerid , o.title as ownertitle, t.contenttypelabel as ownertype
				from dbo.percReport_viewshareddependent d
				inner join contentstatus c on c.contentid = d.dependentid
				inner join psx_objectrelationship r on r.dependent_id = d.dependentid
					and config_id <>3 
				inner join contentstatus o on o.contentid = r.owner_id and (r.owner_revision = -1 or r.owner_revision = o.public_revision)
				inner join contenttypes t on t.contenttypeid = o.contenttypeid
				
				where @contentid is null or d.dependentid = @contentid
			) o
			cross apply dbo.gaogetitemfolderpath2(o.ownerid,'') p 
			cross apply dbo.gaogetitemfolderpath2(o.dependentid,'') d 
		order by dependenttype, dependenttitle
END

GO

























