IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwProtocolDrugActive]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwProtocolDrugActive]
GO

/****** Object:  View dbo.vwProtocolDrugActive    Script Date: 7/5/2006 2:15:46 PM ******/
CREATE view [dbo].[vwProtocolDrugActive]
with schemabinding
as

select
	d.[ProtocolID] ,
	[DrugID]
from dbo.protocoldrug d inner join dbo.Protocol p on d.protocolid = p.protocolid
where p.isactiveprotocol =1



GO
