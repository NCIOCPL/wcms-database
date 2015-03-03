use Percussion
update d set d.template_to_use = 'nvcgDsDynamicListDescImgDate'
from CT_CGVDYNAMICLIST d inner join CONTENTSTATUS c on d.CONTENTID = c.CONTENTID 