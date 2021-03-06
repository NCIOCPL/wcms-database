SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolContactInfoHtmlMap]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProtocolContactInfoHtmlMap](
	[ProtocolContactInfoHtmlID] [int] NOT NULL,
	[ProtocolContactInfoID] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolContactInfoHtmlMap]') AND name = N'CI_ProtocolContactInfoHtmlMap')
CREATE CLUSTERED INDEX [CI_ProtocolContactInfoHtmlMap] ON [dbo].[ProtocolContactInfoHtmlMap] 
(
	[ProtocolContactInfoID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolContactInfoHtmlMap]') AND name = N'NC_protocolcontactinfohtmlmap')
CREATE NONCLUSTERED INDEX [NC_protocolcontactinfohtmlmap] ON [dbo].[ProtocolContactInfoHtmlMap] 
(
	[ProtocolContactInfoHtmlID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_ProtocolContactInfoHtmlMap_ProtocolContactInfoHTML]') AND type = 'F')
ALTER TABLE [dbo].[ProtocolContactInfoHtmlMap]  WITH NOCHECK ADD  CONSTRAINT [FK_ProtocolContactInfoHtmlMap_ProtocolContactInfoHTML] FOREIGN KEY([ProtocolContactInfoHtmlID])
REFERENCES [ProtocolContactInfoHTML] ([ProtocolContactInfoHTMLID])
GO
ALTER TABLE [dbo].[ProtocolContactInfoHtmlMap] CHECK CONSTRAINT [FK_ProtocolContactInfoHtmlMap_ProtocolContactInfoHTML]
GO
