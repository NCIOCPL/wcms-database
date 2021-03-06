SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentPrettyURL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DocumentPrettyURL](
	[DocumentPrettyURLID] [uniqueidentifier] NOT NULL,
	[DocumentID] [uniqueidentifier] NOT NULL,
	[PrettyURL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RealURL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsPrimary] [bit] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DocumentPrettyURL] PRIMARY KEY CLUSTERED 
(
	[DocumentPrettyURLID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DocumentPrettyURL_Document]') AND parent_object_id = OBJECT_ID(N'[dbo].[DocumentPrettyURL]'))
ALTER TABLE [dbo].[DocumentPrettyURL]  WITH CHECK ADD  CONSTRAINT [FK_DocumentPrettyURL_Document] FOREIGN KEY([DocumentID])
REFERENCES [Document] ([DocumentID])
GO
ALTER TABLE [dbo].[DocumentPrettyURL] CHECK CONSTRAINT [FK_DocumentPrettyURL_Document]
GO
