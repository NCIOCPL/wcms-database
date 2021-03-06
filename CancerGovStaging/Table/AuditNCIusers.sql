SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditNCIusers]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditNCIusers](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[userID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[loginName] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[email] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[password] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[lastVisit] [datetime] NULL,
	[secontToLastVist] [datetime] NULL,
	[nSessions] [int] NULL,
	[registrationDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AuditActionDate] [datetime] NOT NULL DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL DEFAULT (user_name()),
	[PasswordLastUpdated] [datetime] NULL
) ON [PRIMARY]
END
GO
