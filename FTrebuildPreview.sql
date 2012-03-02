--X:\SQLFT\ProtocolLive
use CDRPreviewGK
drop fulltext index on dbo.closedprotocolsectionkeyword
drop fulltext index on dbo.activeprotocolsectionkeyword

drop fulltext index on dbo.closedprotocolkeyword
drop fulltext index on dbo.activeprotocolkeyword

drop fulltext index on dbo.protocoldetail

drop fulltext catalog ProtocolPreview

CREATE FULLTEXT CATALOG [ProtocolPreview]in path 'E:\DB'  AS DEFAULT
GO

create fulltext index on dbo.protocoldetail (healthprofessionalTitle, patientTitle, alternateProtocolids, primaryprotocolid, typeofTrial, sponsorofTrial, phase)
KEY INDEX PK_protocolDetail
               WITH          CHANGE_TRACKING OFF



CREATE FULLTEXT INDEX ON dbo.activeProtocolSectionKeyword(HTML )
     KEY INDEX CI_activeProtocolsectionKeyword
               WITH          CHANGE_TRACKING off


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



--closed

CREATE FULLTEXT INDEX ON dbo.closedProtocolSectionKeyword(HTML )
     KEY INDEX CI_closedProtocolsectionKeyword
               WITH          CHANGE_TRACKING off



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
