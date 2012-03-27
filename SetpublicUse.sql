update p set p.public_use =1
from contentstatus c inner join contenttypes t on c.contenttypeid = t.contenttypeid
inner join CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 p on p.contentid = c.contentid
where contenttypename in ('cgvFactsheet','cgvclinicaltrialresult')





