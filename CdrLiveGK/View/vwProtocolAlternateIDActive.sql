IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[vwProtocolAlternateIDActive]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vwProtocolAlternateIDActive]
GO

/****** Object:  View dbo.vwProtocolAlternateIDActive    Script Date: 7/5/2006 2:15:46 PM ******/

Create view dbo.vwProtocolAlternateIDActive
with schemabinding
as

select d.protocolid ,
	 IDstring , idtypeid
	from dbo.ProtocolAlternateID d inner join dbo.Protocol p on d.protocolid = p.protocolid
where p.isactiveprotocol =1


GO
