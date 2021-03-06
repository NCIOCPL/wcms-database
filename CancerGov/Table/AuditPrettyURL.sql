SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditPrettyURL]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditPrettyURL](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PrettyURLID] [uniqueidentifier] NULL,
	[NCIViewID] [uniqueidentifier] NULL,
	[DirectoryID] [uniqueidentifier] NULL,
	[ObjectID] [uniqueidentifier] NULL,
	[RealURL] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CurrentURL] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsNew] [bit] NULL,
	[UpdateRedirectOrNot] [bit] NULL,
	[IsPrimary] [bit] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[AuditActionDate] [datetime] NOT NULL CONSTRAINT [DF__AuditPret__Audit__73901351]  DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__AuditPret__Audit__7484378A]  DEFAULT (user_name()),
	[IsRoot] [bit] NULL
) ON [PRIMARY]
END
GO
