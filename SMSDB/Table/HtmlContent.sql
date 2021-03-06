SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[HtmlContent](
	[HtmlContentID] [uniqueidentifier] NOT NULL,
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ImageHtml] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF_Document_Create_07E124C1]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_Document_Update_08D548FA]  DEFAULT (getdate()),
	[LastRowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[HtmlContentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_document_object]') AND parent_object_id = OBJECT_ID(N'[dbo].[HtmlContent]'))
ALTER TABLE [dbo].[HtmlContent]  WITH CHECK ADD  CONSTRAINT [FK_document_object] FOREIGN KEY([HtmlContentID])
REFERENCES [Object] ([ObjectID])
GO
ALTER TABLE [dbo].[HtmlContent] CHECK CONSTRAINT [FK_document_object]
GO
