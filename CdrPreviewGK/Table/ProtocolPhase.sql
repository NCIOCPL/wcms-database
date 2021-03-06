SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolPhase]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProtocolPhase](
	[ProtocolID] [int] NOT NULL,
	[Phase] [tinyint] NOT NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF__ProtocolP__Updatedate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProtocolPhase_UpdateUserID]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_protocolphase] PRIMARY KEY CLUSTERED 
(
	[ProtocolID] ASC,
	[Phase] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolphase_Protocol]') AND type = 'F')
ALTER TABLE [dbo].[ProtocolPhase]  WITH CHECK ADD  CONSTRAINT [FK_protocolphase_Protocol] FOREIGN KEY([ProtocolID])
REFERENCES [Protocol] ([protocolid])
GO
ALTER TABLE [dbo].[ProtocolPhase] CHECK CONSTRAINT [FK_protocolphase_Protocol]
GO
create index NC_protocolphase on protocolphase (phase)