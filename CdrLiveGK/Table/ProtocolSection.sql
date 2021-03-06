SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolSection]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProtocolSection](
	[ProtocolSectionID] [int] NOT NULL,
	[ProtocolID] [int] NOT NULL,
	[SectionID] [int] NULL,
	[SectionTypeID] [int] NOT NULL,
	[Audience] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HTML] nvarchar(max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolSection]') AND name = N'CI_Protocolsection')
CREATE CLUSTERED INDEX [CI_Protocolsection] ON [dbo].[ProtocolSection] 
(
	[ProtocolID] ASC,
	[SectionTypeID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocolsection_Protocol]') AND type = 'F')
ALTER TABLE [dbo].[ProtocolSection]  WITH CHECK ADD  CONSTRAINT [FK_protocolsection_Protocol] FOREIGN KEY([ProtocolID])
REFERENCES [Protocol] ([protocolid])
GO
ALTER TABLE [dbo].[ProtocolSection] CHECK CONSTRAINT [FK_protocolsection_Protocol]
GO
