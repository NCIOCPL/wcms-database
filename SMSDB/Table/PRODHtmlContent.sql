SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODHtmlContent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODHtmlContent](
	[HtmlContentID] [uniqueidentifier] NOT NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ImageHtml] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF_PRODDocument_Create]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_PRODDocument_Update]  DEFAULT (getdate()),
	[LastRowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_PRODDocument] PRIMARY KEY CLUSTERED 
(
	[HtmlContentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODdocument_object]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODHtmlContent]'))
ALTER TABLE [dbo].[PRODHtmlContent]  WITH CHECK ADD  CONSTRAINT [FK_PRODdocument_object] FOREIGN KEY([HtmlContentID])
REFERENCES [PRODObject] ([ObjectID])
GO
ALTER TABLE [dbo].[PRODHtmlContent] CHECK CONSTRAINT [FK_PRODdocument_object]
GO
