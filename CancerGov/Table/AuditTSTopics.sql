SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditTSTopics]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditTSTopics](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TopicId] [uniqueidentifier] NULL,
	[TopicName] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TopicSearchTerm] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EditableTopicSearchTerm] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updateuserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updateDate] [datetime] NULL,
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (user_name()),
	[AuditActionDate] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
