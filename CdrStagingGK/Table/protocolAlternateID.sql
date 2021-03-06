SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolAlternateID]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[protocolAlternateID](
	[protocolid] [int] NOT NULL,
	[IDstring] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF__protocolA__updatedate]  DEFAULT (getdate()),
	[updateUserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__protocolA__updateUserID]  DEFAULT (suser_sname()),
	[idtypeid] [tinyint] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[protocolAlternateID]') AND name = N'CI_protoocolalternateid')
CREATE CLUSTERED INDEX [CI_protoocolalternateid] ON [dbo].[protocolAlternateID] 
(
	[protocolid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolalternateid_alternateIDtype]') AND type = 'F')
ALTER TABLE [dbo].[protocolAlternateID]  WITH CHECK ADD  CONSTRAINT [FK_protocolalternateid_alternateIDtype] FOREIGN KEY([idtypeid])
REFERENCES [AlternateIDtype] ([idtypeid])
GO
ALTER TABLE [dbo].[protocolAlternateID] CHECK CONSTRAINT [FK_protocolalternateid_alternateIDtype]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolAlternateID_Protocol]') AND type = 'F')
ALTER TABLE [dbo].[protocolAlternateID]  WITH CHECK ADD  CONSTRAINT [FK_protocolAlternateID_Protocol] FOREIGN KEY([protocolid])
REFERENCES [Protocol] ([protocolid])
GO
ALTER TABLE [dbo].[protocolAlternateID] CHECK CONSTRAINT [FK_protocolAlternateID_Protocol]
GO
