SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocumentData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DocumentData](
	[RequestDataID] [int] NOT NULL,
	[Data] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [DocumentData_PK] PRIMARY KEY CLUSTERED 
(
	[RequestDataID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DocumentData_requestData]') AND parent_object_id = OBJECT_ID(N'[dbo].[DocumentData]'))
ALTER TABLE [dbo].[DocumentData]  WITH CHECK ADD  CONSTRAINT [FK_DocumentData_requestData] FOREIGN KEY([RequestDataID])
REFERENCES [RequestData] ([RequestDataID])
GO
ALTER TABLE [dbo].[DocumentData] CHECK CONSTRAINT [FK_DocumentData_requestData]
GO
