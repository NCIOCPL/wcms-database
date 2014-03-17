use CDRLiveGk
CREATE FULLTEXT STOPLIST CTstoplist FROM SYSTEM STOPLIST;

ALTER FULLTEXT STOPLIST CTstoplist drop 'her' LANGUAGE 'english';

ALTER FULLTEXT INDEX ON ActiveProtocolsectionKeyword SET STOPLIST = CTstoplist
alter fulltext index on protocolDetail set stoplist CTstoplist
alter fulltext index on activeProtocolKeyword set stoplist CTstoplist

alter fulltext index on closedprotocolsectionKeyword set stoplist CTstoplist
alter fulltext index on closedProtocolKeyword set stoplist CTstoplist

EXEC sp_fulltext_catalog 'protocollive', 'start_full';

use CDRpreviewGK
CREATE FULLTEXT STOPLIST CTstoplist FROM SYSTEM STOPLIST;

ALTER FULLTEXT STOPLIST CTstoplist drop 'her' LANGUAGE 'english';

ALTER FULLTEXT INDEX ON ActiveProtocolsectionKeyword SET STOPLIST = CTstoplist
alter fulltext index on protocolDetail set stoplist CTstoplist
alter fulltext index on activeProtocolKeyword set stoplist CTstoplist

alter fulltext index on closedprotocolsectionKeyword set stoplist CTstoplist
alter fulltext index on closedProtocolKeyword set stoplist CTstoplist

EXEC sp_fulltext_catalog 'protocolpreview', 'start_full';
