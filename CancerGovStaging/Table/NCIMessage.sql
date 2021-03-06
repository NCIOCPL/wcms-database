SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCIMessage]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NCIMessage](
	[MessageID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_NCIMessage_MessageID]  DEFAULT (newid()),
	[SenderID] [uniqueidentifier] NOT NULL,
	[RecipientID] [uniqueidentifier] NOT NULL,
	[Subject] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Message] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SendDate] [datetime] NOT NULL CONSTRAINT [DF_NCIMessage_SendDate]  DEFAULT (getdate()),
	[DeleteDate] [datetime] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_NCIMessage_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_NCIMessage_UpdateUserID]  DEFAULT (user_name()),
 CONSTRAINT [PK_NCIMessage] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[NCIMessage] TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([MessageID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([SenderID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([RecipientID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([Subject]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([Message]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([Status]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([SendDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([DeleteDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([UpdateDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCIMessage] ([UpdateUserID]) TO [webadminuser_role]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NCIMessage_NCIUsers]') AND type = 'F')
ALTER TABLE [dbo].[NCIMessage]  WITH CHECK ADD  CONSTRAINT [FK_NCIMessage_NCIUsers] FOREIGN KEY([SenderID])
REFERENCES [NCIUsers] ([userID])
GO
ALTER TABLE [dbo].[NCIMessage] CHECK CONSTRAINT [FK_NCIMessage_NCIUsers]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NCIMessage_NCIUsers1]') AND type = 'F')
ALTER TABLE [dbo].[NCIMessage]  WITH CHECK ADD  CONSTRAINT [FK_NCIMessage_NCIUsers1] FOREIGN KEY([RecipientID])
REFERENCES [NCIUsers] ([userID])
GO
ALTER TABLE [dbo].[NCIMessage] CHECK CONSTRAINT [FK_NCIMessage_NCIUsers1]
GO
