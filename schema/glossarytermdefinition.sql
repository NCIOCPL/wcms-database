use cdrlivegk
alter table glossarytermdefinition add AudioMediaHTML ntext
use cdrstaginggk
alter table glossarytermdefinition add AudioMediaHTML ntext
use cdrPreviewgk
alter table glossarytermdefinition add AudioMediaHTML ntext


use cdrlivegk
alter table GlossaryTermDefinition add RelatedInformationHtml ntext

use cdrpreviewgk
alter table GlossaryTermDefinition add RelatedInformationHtml ntext


use cdrstaginggk
alter table GlossaryTermDefinition add RelatedInformationHtml ntext