if object_id('percReport_getSlotRelationship') is not null
	drop procedure dbo.percReport_getSlotRelationship
go
create procedure dbo.percReport_getSlotRelationship ( @slotname varchar(500))
as
BEGIN

	select s.LABEL , owner_id, DEPENDENT_ID, contenttypeid  , c1.title
	, 1 as rev --current
	into #t
	from dbo.PSX_OBJECTRELATIONSHIP r 
	inner join RXSLOTTYPE s on r.SLOT_ID = s.SLOTID 
	inner join contentstatus c1 on c1.contentid = r.owner_ID and c1.currentREVISION  = r.OWNER_REVISION 
	where s.slotname = @slotname 

	insert into #t
	select s.LABEL ,OWNER_ID, DEPENDENT_ID, contenttypeid  , c1.title
	, 2 --public
	from dbo.PSX_OBJECTRELATIONSHIP r 
	inner join RXSLOTTYPE s on r.SLOT_ID = s.SLOTID 
	inner join contentstatus c1 on c1.contentid = r.owner_ID and c1.PUBLIC_REVISION  = r.OWNER_REVISION 
		where s.slotname = @slotname 

	insert into #t 
	select s.LABEL , OWNER_ID, DEPENDENT_ID, contenttypeid , c1.title
	, 4  --edit
	from dbo.PSX_OBJECTRELATIONSHIP r 
	inner join RXSLOTTYPE s on r.SLOT_ID = s.SLOTID 
	inner join contentstatus c1 on c1.contentid = r.owner_ID and c1.EDITREVISION  = r.OWNER_REVISION  
	where s.slotname = @slotname 

	select LABEL, a.owner_id as ownerID, a.title as ownerTitle, dbo.gaogetitemFolderPath(a.OWNER_ID,'') as ownerPath, t1.CONTENTTYPENAME as ownerType
	, c.contentid as dependentID, c.title as dependentTitle, dbo.gaogetitemFolderPath(c.contentid,'') as dependentPath, ct.CONTENTTYPENAME as dependentType
	, case  revisions 
		when 1 then 'currentOnly'
		when 2 then 'publicOnly' 
		when 3 then 'public&current' 
		when 4 then 'editOnly' 
		when 5 then 'current&edit' 
		when 7 then 'current&public&edit' 
			 ELSE ''
	END as whichRevision
	 from
	(
		select owner_id, dependent_id, contenttypeid, label  , title,  sum(rev) as revisions
		from #t
		group by owner_id, dependent_id, contenttypeid, label, title
		) a
		inner join contentstatus c on c.contentid = a.DEPENDENT_ID
		inner join contenttypes ct on ct.contenttypeid = c.contenttypeid 
		inner join contenttypes t1 on t1.contenttypeid = a.contenttypeid 
	order by owner_id , 10


	

	
END
go


exec percReport_getSlotRelationship 'nvcgSlBodyLayout'












