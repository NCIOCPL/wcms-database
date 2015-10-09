update c set c.contentstateid = (select stateid from states where WORKFLOWAPPID  = 6 and statename = 'Editing (P)')
from contentstatus c 
where c.WORKFLOWAPPID = 6 
and contentstateid not in (select stateid from states where WORKFLOWAPPID  = 6)
and c.CONTENTSTATEID = 4

