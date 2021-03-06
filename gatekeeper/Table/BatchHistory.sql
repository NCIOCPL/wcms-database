SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BatchHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BatchHistory](
	[BatchHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[Entry] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EntryDateTime] [smalldatetime] NOT NULL DEFAULT (getdate()),
	[UserName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BatchID] [int] NOT NULL,
 CONSTRAINT [BatchHistory_PK] PRIMARY KEY CLUSTERED 
(
	[BatchHistoryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Batch_BatchHistory_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[BatchHistory]'))
ALTER TABLE [dbo].[BatchHistory]  WITH CHECK ADD  CONSTRAINT [Batch_BatchHistory_FK1] FOREIGN KEY([BatchID])
REFERENCES [Batch] ([BatchID])
GO
ALTER TABLE [dbo].[BatchHistory] CHECK CONSTRAINT [Batch_BatchHistory_FK1]
GO
