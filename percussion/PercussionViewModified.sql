use percussion 
go
drop view dbo.RXVARIANTCOMMUNITY 
GO
create view dbo.RXVARIANTCOMMUNITY 
as 
select p.OBJECTID VARIANTID, p.COMMUNITYID 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p 
where p.OBJECTTYPE = 4 and p.PERMISSION = 40
go



drop view dbo.RXWORKFLOWCOMMUNITY 
GO
create view dbo.RXWORKFLOWCOMMUNITY 
as 
select p.OBJECTID WORKFLOWAPPID, p.COMMUNITYID 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p 
where p.OBJECTTYPE = 23 and p.PERMISSION = 40
go



drop view dbo.PSX_DISPLAYFORMATPROPERTY_VIEW 
GO
create view dbo.PSX_DISPLAYFORMATPROPERTY_VIEW 
as 
select * 
from Percussion.dbo.PSX_DISPLAYFORMATPROPERTIES 
union 
select p.OBJECTID PROPERTYID, 'sys_community' PROPERTYNAME, ltrim(str(p.COMMUNITYID)) PROPERTYVALUE, 'from acls' DESCRIPTION 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p 
where p.OBJECTTYPE = 31
go


drop view dbo.PSX_SEARCHPROPERTIES_VIEW
GO
create view dbo.PSX_SEARCHPROPERTIES_VIEW 
as 
select * 
from Percussion.dbo.PSX_SEARCHPROPERTIES 
union 
select p.OBJECTID PROPERTYID, 'sys_community' PROPERTYNAME, ltrim(str(p.COMMUNITYID)) PROPERTYVALUE, 'from acls' DESCRIPTION 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p 
where p.OBJECTTYPE = 15 OR p.OBJECTTYPE = 18
go


drop view dbo.PSX_MENUVISIBILITY_VIEW 
GO
create view dbo.PSX_MENUVISIBILITY_VIEW 
as 
select * 
from Percussion.dbo.RXMENUVISIBILITY 
where VISIBILITYCONTEXT <> '2' 
union 
select a.ACTIONID, '2' VISIBILITYCONTEXT, ltrim(str(C.COMMUNITYID)) VALUE, 'from acls' DESCRIPTION 
from Percussion.dbo.RXMENUACTION a, Percussion.dbo.RXCOMMUNITY C 
where 
(select count(*) 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p 
where p.OBJECTTYPE = 107 and p.OBJECTID = a.ACTIONID and (C.COMMUNITYID = COMMUNITYID) and p.PERMISSION = 40) = 0 and 
(select count(*) from Percussion.dbo.PSX_ACLS ACL 
where OBJECTTYPE = 107 and OBJECTID = a.ACTIONID) <> 0

go



drop view dbo.RXSITEITEMS
GO
 create view dbo.RXSITEITEMS 
 AS 
 select PD.PUBSTATUSID, PD.CONTENTID, PD.VARIANTID, PD.LOCATIONHASH, PD.PUBSTATUS, PD.PUBDATE, PD.PUBOP AS PUBOPERATION, PD.PUBLOCATION AS LOCATION,
  PD.CONTENTURL, PD.VERSIONID, PD.REVISIONID, PD.ELAPSETIME, PD.REFERENCE_ID, PSI.SITE_ID AS SITEID, PSI.CONTEXT_ID AS CONTEXT 
  from Percussion.dbo.PSX_PUBLICATION_SITE_ITEM PSI 
  inner join percussion.dbo.RXPUBDOCS PD on PSI.REFERENCE_ID = PD.REFERENCE_ID

  go




drop view dbo.RXSITECOMMUNITY
GO
create view dbo.RXSITECOMMUNITY 
as 
select p.OBJECTID SITEID, p.COMMUNITYID 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p where p.OBJECTTYPE = 9 and p.PERMISSION = 40
go



drop view dbo.RXCONTENTTYPECOMMUNITY 
GO
create view dbo.RXCONTENTTYPECOMMUNITY 
as 
select p.OBJECTID CONTENTTYPEID, p.COMMUNITYID 
from percussion.dbo.PSX_COMMUNITY_PERMISSION_VIEW p 
where p.OBJECTTYPE = 2 and p.PERMISSION = 40
