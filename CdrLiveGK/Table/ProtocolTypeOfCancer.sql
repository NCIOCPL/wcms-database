SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolTypeOfCancer]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProtocolTypeOfCancer](
	[ProtocolID] [int] NOT NULL,
	[DiagnosisID] [int] NOT NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_ProtocolTypeOfCancer_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProtocolTypeOfCancer_UpdateUserID]  DEFAULT (suser_sname())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolTypeOfCancer]') AND name = N'CI_protocoltypeofcancer')
CREATE CLUSTERED INDEX [CI_protocoltypeofcancer] ON [dbo].[ProtocolTypeOfCancer] 
(
	[ProtocolID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolTypeOfCancer]') AND name = N'NC_protocolTypeofCancer_diagnosisid')
CREATE NONCLUSTERED INDEX [NC_protocolTypeofCancer_diagnosisid] ON [dbo].[ProtocolTypeOfCancer] 
(
	[DiagnosisID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolTypeOfCancer_Protocol]') AND type = 'F')
ALTER TABLE [dbo].[ProtocolTypeOfCancer]  WITH CHECK ADD  CONSTRAINT [FK_protocolTypeOfCancer_Protocol] FOREIGN KEY([ProtocolID])
REFERENCES [Protocol] ([protocolid])
GO
ALTER TABLE [dbo].[ProtocolTypeOfCancer] CHECK CONSTRAINT [FK_protocolTypeOfCancer_Protocol]
GO
