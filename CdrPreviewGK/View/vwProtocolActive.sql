IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwProtocolActive]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwProtocolActive]
GO




/****** Object:  View dbo.vwProtocolActive    Script Date: 7/5/2006 2:15:46 PM ******/
create view dbo.vwProtocolActive
with schemabinding
as

select 
protocolid ,
[IsNew] ,
[IsNIHClinicalCenterTrial],
[IsActiveProtocol] 
from dbo.protocol where isactiveprotocol =1


GO
