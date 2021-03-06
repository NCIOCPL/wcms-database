SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Document]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Document](
	[DocumentID] [int] NOT NULL,
	[DocumentGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Document_DocumentGUID]  DEFAULT (newid()),
	[DocumentTypeID] [int] NOT NULL,
	[Version] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Document_Version]  DEFAULT (1),
	[IsActive] [bit] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Document_UpdateDate]  DEFAULT (getdate()),
	[DateLastModified] [datetime] NULL,
	[Status] [tinyint] NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[DocumentID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Document]') AND name = N'NC_document_documentGUID')
CREATE NONCLUSTERED INDEX [NC_document_documentGUID] ON [dbo].[Document] 
(
	[DocumentGUID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_Document_DocumentType]') AND type = 'F')
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_DocumentType] FOREIGN KEY([DocumentTypeID])
REFERENCES [DocumentType] ([DocumentTypeID])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_DocumentType]
GO
