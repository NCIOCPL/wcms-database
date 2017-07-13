
update i 
set i.img6 = i.img4
, i.img6_filename = replace(i.IMG4_FILENAME, '.', '-sm.')
, i.IMG6_EXT = i.IMG4_EXT
, i.IMG6_HEIGHT = i.IMG4_HEIGHT
, i.IMG6_SIZE = i.IMG4_SIZE
, i.IMG6_TYPE= i.IMG4_TYPE
, i.IMG6_WIDTH = i.IMG4_WIDTH 
from percussion.dbo.ct_genimage i inner join contentstatus c on i.contentid = c.contentid and i.REVISIONID = c.CURRENTREVISION
where IMG4_FILENAME is not null 