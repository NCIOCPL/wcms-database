SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditNCIMessage]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditNCIMessage](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MessageID] [uniqueidentifier] NULL,
	[SenderID] [uniqueidentifier] NULL,
	[RecipientID] [uniqueidentifier] NULL,
	[Subject] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Message] [varchar](6000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SendDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditActionDate] [datetime] NOT NULL DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (user_name())
) ON [PRIMARY]
END
GO
