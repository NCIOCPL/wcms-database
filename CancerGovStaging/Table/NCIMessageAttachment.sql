SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCIMessageAttachment]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NCIMessageAttachment](
	[AttachmentID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_NCIMessageAttachment_AttachmentID]  DEFAULT (newid()),
	[MessageID] [uniqueidentifier] NOT NULL,
	[ObjectID] [uniqueidentifier] NULL,
	[ObjectType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AttachmentText] [varchar](7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_NCIMessageAttachment_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NCIMessageAttachment_UpdateUserID]  DEFAULT (user_name()),
 CONSTRAINT [PK_NCIMessageAttachment] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NCIMessageAttachment_NCIMessage]') AND type = 'F')
ALTER TABLE [dbo].[NCIMessageAttachment]  WITH CHECK ADD  CONSTRAINT [FK_NCIMessageAttachment_NCIMessage] FOREIGN KEY([MessageID])
REFERENCES [NCIMessage] ([MessageID])
GO
ALTER TABLE [dbo].[NCIMessageAttachment] CHECK CONSTRAINT [FK_NCIMessageAttachment_NCIMessage]
GO
