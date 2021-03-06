SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolSearchContactCache]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProtocolSearchContactCache](
	[ProtocolSearchID] [int] NULL,
	[ProtocolContactInfoID] [int] NULL,
	[ProtocolID] [int] NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolSearchContactCache]') AND name = N'IX_ProtocolSearchContactCache_ProtocolSearchID')
CREATE CLUSTERED INDEX [IX_ProtocolSearchContactCache_ProtocolSearchID] ON [dbo].[ProtocolSearchContactCache] 
(
	[ProtocolSearchID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_ProtocolSearchContactCache_ProtocolSearch]') AND type = 'F')
ALTER TABLE [dbo].[ProtocolSearchContactCache]  WITH CHECK ADD  CONSTRAINT [FK_ProtocolSearchContactCache_ProtocolSearch] FOREIGN KEY([ProtocolSearchID])
REFERENCES [ProtocolSearch] ([ProtocolSearchID])
GO
ALTER TABLE [dbo].[ProtocolSearchContactCache] CHECK CONSTRAINT [FK_ProtocolSearchContactCache_ProtocolSearch]
GO
