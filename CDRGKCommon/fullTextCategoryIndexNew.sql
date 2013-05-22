alter table protocolsection alter column HTML nvarchar(max)
GO

exec sp_fulltext_database 'enable'
GO
if db_name() = 'cdrLivegk'
CREATE FULLTEXT CATALOG [ProtocolLive]in path 'X:\SQLFT'  AS DEFAULT
GO
if db_name() = 'cdrPreviewgk'
CREATE FULLTEXT CATALOG [ProtocolPreview] in path 'X:\SQLFT' AS DEFAULT

--SELECT name, ftcatid FROM sysobjects WHERE ftcatid > 0
----------

---Title, alternateID, typeofTrial, sponsorofTrial
if objectproperty(object_id('protocoldetail'),'TableHasActiveFulltextIndex') = 1
drop fulltext index on dbo.ProtocolDetail
GO
create fulltext index on dbo.protocoldetail (healthprofessionalTitle, patientTitle, alternateProtocolids, primaryprotocolid, typeofTrial, sponsorofTrial, phase)
KEY INDEX PK_protocolDetail
               WITH          CHANGE_TRACKING OFF


---------------------------
----------------------------------------------------------

GO

drop function dbo.udf_getSectionForprotocol
go
create function dbo.udf_getSectionForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + html
from dbo.protocolsection with (nolock)
where protocolid = @protocolid
return @s
end
GO

--- personGivenName, personSurName , organizationname
--- TrialSite
drop function dbo.udf_getTrialSiteForprotocol
GO
create function dbo.udf_getTrialSiteForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + o.Name 
from dbo.protocolTrialsite t with (nolock) inner join dbo.organizationname o with (nolock) on t.organizationid = o.organizationid
where protocolid = @protocolid
return @s
end
GO

drop function dbo.udf_getLeadOrgForprotocol
GO
create function dbo.udf_getLeadOrgForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + o.Name 
from dbo.protocolLeadOrg t with (nolock) inner join dbo.organizationname o with (nolock) on t.organizationid = o.organizationid
where protocolid = @protocolid
return @s
end
GO

drop function dbo.udf_getInvestigatorForprotocol
GO
create function dbo.udf_getInvestigatorForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + personGivenName+ ' ' + personSurName
from dbo.protocolLeadOrg with (nolock)
where protocolid = @protocolid and (personGivenName is not NULL or personSurName is not NULL)
select  @s = @s+ ',' + personGivenName+ ' ' + personSurName
from dbo.protocolTrialSite with (nolock)
where protocolid = @protocolid and (personGivenName is not NULL or personSurName is not NULL)
return @s
end
GO


drop function dbo.udf_getSpecialCategoryForprotocol
go
create function dbo.udf_getSpecialCategoryForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + protocolspecialCategory
from dbo.protocolspecialcategory with (nolock)
where protocolid = @protocolid 
return @s
end
GO

--drop function dbo.udf_getDrugForprotocol
--GO
drop function dbo.udf_getDrugForprotocol
go

create function dbo.udf_getDrugForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + d.drugName
from protocolDrug  pt  with (nolock)
inner join TermDrug  d  with (nolock)  on pt.drugid = d.Termid
where protocolid = @protocolid
return @s
end
GO



drop function dbo.udf_getInterventionForprotocol
GO
create function dbo.udf_getInterventionForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + d.interventionName
from protocolModality pt with (nolock)
inner join InterventionName d with (nolock) on pt.modalityid = d.interventionid
where protocolid = @protocolid
return @s
end

GO

drop function dbo.udf_getTypeofCancerForprotocol
go
create function dbo.udf_getTypeofCancerForprotocol
(@protocolid int)
returns nvarchar(max)
as 
begin
declare @s nvarchar(max)
select @s = ''
select  @s = @s+ ',' + d.diagnosisName 
from protocoltypeofcancer pt with (nolock) inner join diagnosisName d with (nolock) on pt.diagnosisid = d.diagnosisid
where protocolid = @protocolid
return @s
end
GO

----------------------

















--exec dbo.termdrugreload

if object_id('InterventionName') is not null
drop table dbo.InterventionName
GO
create table dbo.InterventionName (Interventionid int, InterventionName nvarchar(2200))
insert into dbo.InterventionName
select distinct t.termid, t.preferredname from terminology t inner join termsemantictype s on t.termid = s.termid
where semantictypename = 'Intervention or procedure'
union 
select distinct t.termid, ton.othername from terminology t inner join termsemantictype s on t.termid = s.termid
inner join termothername ton on ton.termid = t.termid
where semantictypename = 'Intervention or procedure'
Go
create clustered index CI_InterventionName on dbo.interventionName (InterventionID)

---------
if object_id('DiagnosisName') is not null
drop table dbo.DiagnosisName
GO
create table dbo.DiagnosisName (Diagnosisid int, diagnosisName nvarchar(2200))
insert into dbo.DiagnosisName
select distinct t.termid, t.preferredname from terminology t inner join termsemantictype s on t.termid = s.termid
where semantictypename in ('Cancer diagnosis', 'Cancer stage', 'Secondary related condition')
union 
select distinct t.termid, ton.othername from terminology t inner join termsemantictype s on t.termid = s.termid
inner join termothername ton on ton.termid = t.termid
where semantictypename in ('Cancer diagnosis', 'Cancer stage', 'Secondary related condition')
Go
create clustered index CI_diagnosisName on dbo.diagnosisName (diagnosisID)
GO



-----------------

--SectionHTML
create table dbo.activeprotocolsectionKeyword 
(protocolid int NOT NULL, html nvarchar(max))
GO
insert into dbo.activeprotocolsectionKeyword
select protocolid , dbo.udf_getSectionForprotocol(protocolid)
from dbo.protocol where isactiveprotocol = 1
GO
create unique clustered  index CI_activeprotocolsectionKeyword on dbo.Activeprotocolsectionkeyword(protocolid)
GO


if objectproperty(object_id('ActiveprotocolSectionKeyword'),'TableHasActiveFulltextIndex') = 1
drop fulltext index on dbo.activeProtocolSectionKeyword
GO
CREATE FULLTEXT INDEX ON dbo.activeProtocolSectionKeyword(HTML )
     KEY INDEX CI_activeProtocolsectionKeyword
               WITH          CHANGE_TRACKING off

--------------------




create table dbo.activeProtocolKeyword (
protocolid int NOT NULL, 
trialsite varchar(max),
leadorg varchar(max),
investigator varchar(max),
specialcategory varchar(max),
drug varchar(max),
intervention varchar(max),
typeofCancer varchar(max)
)

insert into dbo.activeProtocolKeyword
(protocolid, 
trialsite,
leadorg,
investigator,
specialcategory,
drug,
intervention,
typeofCancer)
select 
protocolid,
case isactiveprotocol when 1 then dbo.udf_getTrialSiteForprotocol(protocolid) else NULL end,  
dbo.udf_getLeadOrgForprotocol(protocolid),  
dbo.udf_getInvestigatorForProtocol(protocolid),
dbo.udf_getSpecialCategoryForprotocol(protocolid),
dbo.udf_getDrugForprotocol(protocolid),
dbo.udf_getInterventionForprotocol(protocolid) ,
dbo.udf_getTypeofCancerForprotocol(protocolid)
from dbo.protocol where isactiveprotocol = 1

create unique clustered index CI_activeProtocolKeyword on dbo.activeProtocolKeyword(protocolid)

if objectproperty(object_id('activeProtocolKeyword'),'TableHasActiveFulltextIndex') = 1
drop fulltext index on dbo.activeProtocolKeyword
GO
Create fulltext index on activeProtocolKeyword (
trialsite,
leadorg,
investigator,
specialcategory,
drug,
intervention,
typeofCancer)
key index CI_activeProtocolKeyword
WITH          CHANGE_TRACKING OFF 

GO


-----------------------
----------------------
--closed

--SectionHTML
create table dbo.closedprotocolsectionKeyword 
(protocolid int NOT NULL, html nvarchar(max))
GO
insert into dbo.closedprotocolsectionKeyword
select protocolid , dbo.udf_getSectionForprotocol(protocolid)
from dbo.protocol where isActiveprotocol = 0
GO
create unique clustered  index CI_closedprotocolsectionKeyword on dbo.closedprotocolsectionkeyword(protocolid)
GO


if objectproperty(object_id('closedprotocolSectionKeyword'),'TableHasActiveFulltextIndex') = 1
drop fulltext index on dbo.closedProtocolSectionKeyword
GO
CREATE FULLTEXT INDEX ON dbo.closedProtocolSectionKeyword(HTML )
     KEY INDEX CI_closedProtocolsectionKeyword
               WITH          CHANGE_TRACKING off

--------------------




create table dbo.closedProtocolKeyword (
protocolid int NOT NULL, 
trialsite varchar(max),
leadorg varchar(max),
investigator varchar(max),
specialcategory varchar(max),
drug varchar(max),
intervention varchar(max),
typeofCancer varchar(max)
)

insert into dbo.closedProtocolKeyword
(protocolid, 
trialsite,
leadorg,
investigator,
specialcategory,
drug,
intervention,
typeofCancer)
select 
protocolid,
case isActiveprotocol when 1 then dbo.udf_getTrialSiteForprotocol(protocolid) else NULL end,  
dbo.udf_getLeadOrgForprotocol(protocolid),  
dbo.udf_getInvestigatorForProtocol(protocolid),
dbo.udf_getSpecialCategoryForprotocol(protocolid),
dbo.udf_getDrugForprotocol(protocolid),
dbo.udf_getInterventionForprotocol(protocolid) ,
dbo.udf_getTypeofCancerForprotocol(protocolid)
from dbo.protocol where isActiveprotocol = 0

create unique clustered index CI_closedProtocolKeyword on dbo.closedProtocolKeyword(protocolid)

if objectproperty(object_id('closedProtocolKeyword'),'TableHasActiveFulltextIndex') = 1
drop fulltext index on dbo.closedProtocolKeyword
GO
Create fulltext index on closedProtocolKeyword (
trialsite,
leadorg,
investigator,
specialcategory,
drug,
intervention,
typeofCancer)
key index CI_closedProtocolKeyword
WITH          CHANGE_TRACKING OFF 

GO


-----------------------
