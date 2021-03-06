SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NLIssue]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NLIssue](
	[NewsletterID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
	[NCIViewID] [uniqueidentifier] NOT NULL,
	[Priority] [int] NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NLIssue_Status]  DEFAULT ('UNSENT'),
	[SendDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__NLIssue__UpdateU__50D0E6F9]  DEFAULT (user_name()),
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[IssueType] [int] NULL CONSTRAINT [DF_NLIssue_IssueType]  DEFAULT (1),
 CONSTRAINT [PK_NLIssue] PRIMARY KEY CLUSTERED 
(
	[NewsletterID] ASC,
	[NCIViewID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NLIssue_NCIView]') AND type = 'F')
ALTER TABLE [dbo].[NLIssue]  WITH NOCHECK ADD  CONSTRAINT [FK_NLIssue_NCIView] FOREIGN KEY([NCIViewID])
REFERENCES [NCIView] ([NCIViewID])
GO
ALTER TABLE [dbo].[NLIssue] CHECK CONSTRAINT [FK_NLIssue_NCIView]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_NLIssue_Newsletter]') AND type = 'F')
ALTER TABLE [dbo].[NLIssue]  WITH NOCHECK ADD  CONSTRAINT [FK_NLIssue_Newsletter] FOREIGN KEY([NewsletterID])
REFERENCES [Newsletter] ([NewsletterID])
GO
ALTER TABLE [dbo].[NLIssue] CHECK CONSTRAINT [FK_NLIssue_Newsletter]
GO
