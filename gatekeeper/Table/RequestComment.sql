SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RequestComment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RequestComment](
	[CommentID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[CommentDate] [datetime] NOT NULL DEFAULT (getdate()),
	[Comment] [varchar](8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK__RequestComment__367C1819] PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RequestComment_request]') AND parent_object_id = OBJECT_ID(N'[dbo].[RequestComment]'))
ALTER TABLE [dbo].[RequestComment]  WITH CHECK ADD  CONSTRAINT [FK_RequestComment_request] FOREIGN KEY([RequestID])
REFERENCES [Request] ([RequestID])
GO
ALTER TABLE [dbo].[RequestComment] CHECK CONSTRAINT [FK_RequestComment_request]
GO
