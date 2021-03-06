SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DocumentType](
	[DocumentTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IconPath] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Extension] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MimeType] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_DocumentType] PRIMARY KEY CLUSTERED 
(
	[DocumentTypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
