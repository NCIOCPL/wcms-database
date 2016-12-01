if object_id('percReport_getAllslots') is not null
	drop procedure dbo.percReport_getAllslots 
GO
create procedure dbo.percReport_getAllSlots 
as
BEGIN
	select slotname from dbo.RXSLOTTYPE order by slotname 
END


