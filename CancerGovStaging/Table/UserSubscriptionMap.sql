SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[UserSubscriptionMap]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[UserSubscriptionMap](
	[NewsletterID] [uniqueidentifier] NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[EmailFormat] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SubscriptionDate] [datetime] NOT NULL CONSTRAINT [DF_UserSubscriptionMap_SubscriptionDate]  DEFAULT (getdate()),
	[KeywordList] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__UserSubsc__Updat__55959C16]  DEFAULT (user_name()),
	[IsSubscribed] [bit] NULL,
	[UnSubscribeDate] [datetime] NULL,
	[Priority] [int] NOT NULL CONSTRAINT [DF_UserSubscriptionMap_Priority]  DEFAULT (9999),
 CONSTRAINT [PK_UserSubscriptionMap] PRIMARY KEY CLUSTERED 
(
	[NewsletterID] ASC,
	[UserID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_UserSubscriptionMap_NCIUsers]') AND type = 'F')
ALTER TABLE [dbo].[UserSubscriptionMap]  WITH NOCHECK ADD  CONSTRAINT [FK_UserSubscriptionMap_NCIUsers] FOREIGN KEY([UserID])
REFERENCES [NCIUsers] ([userID])
GO
ALTER TABLE [dbo].[UserSubscriptionMap] CHECK CONSTRAINT [FK_UserSubscriptionMap_NCIUsers]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_UserSubscriptionMap_Newsletter]') AND type = 'F')
ALTER TABLE [dbo].[UserSubscriptionMap]  WITH NOCHECK ADD  CONSTRAINT [FK_UserSubscriptionMap_Newsletter] FOREIGN KEY([NewsletterID])
REFERENCES [Newsletter] ([NewsletterID])
GO
ALTER TABLE [dbo].[UserSubscriptionMap] CHECK CONSTRAINT [FK_UserSubscriptionMap_Newsletter]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[CK_UserSubscriptionMap]') AND type = 'C')
ALTER TABLE [dbo].[UserSubscriptionMap]  WITH CHECK ADD  CONSTRAINT [CK_UserSubscriptionMap] CHECK  (([EmailFormat] = 'HTML' or [EmailFormat] = 'TEXT'))
GO
ALTER TABLE [dbo].[UserSubscriptionMap] CHECK CONSTRAINT [CK_UserSubscriptionMap]
GO
