SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolsponsors]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[protocolsponsors](
	[protocolid] [int] NOT NULL,
	[sponsorid] [tinyint] NOT NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF__protocolsp__updateDate]  DEFAULT (getdate()),
	[updateuserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__protocolsp__updateUserid]  DEFAULT (suser_sname())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[protocolsponsors]') AND name = N'CI_protocolsponsors')
CREATE CLUSTERED INDEX [CI_protocolsponsors] ON [dbo].[protocolsponsors] 
(
	[protocolid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[protocolsponsors]') AND name = N'NC_protocolSponsors')
CREATE NONCLUSTERED INDEX [NC_protocolSponsors] ON [dbo].[protocolsponsors] 
(
	[sponsorid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolsponsor_Protocol]') AND type = 'F')
ALTER TABLE [dbo].[protocolsponsors]  WITH CHECK ADD  CONSTRAINT [FK_protocolsponsor_Protocol] FOREIGN KEY([protocolid])
REFERENCES [Protocol] ([protocolid])
GO
ALTER TABLE [dbo].[protocolsponsors] CHECK CONSTRAINT [FK_protocolsponsor_Protocol]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolsponsors_sponsor]') AND type = 'F')
ALTER TABLE [dbo].[protocolsponsors]  WITH CHECK ADD  CONSTRAINT [FK_protocolsponsors_sponsor] FOREIGN KEY([sponsorid])
REFERENCES [sponsor] ([sponsorid])
GO
ALTER TABLE [dbo].[protocolsponsors] CHECK CONSTRAINT [FK_protocolsponsors_sponsor]
GO
