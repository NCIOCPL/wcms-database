SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[AuditTaskStep]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[AuditTaskStep](
	[AuditActionType] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StepID] [uniqueidentifier] NOT NULL,
	[TaskID] [uniqueidentifier] NOT NULL,
	[ResponsibleGroupID] [int] NULL,
	[Name] [varchar](75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Status] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrderLevel] [int] NOT NULL,
	[AprvStoredProcedure] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DisAprvStoredProcedure] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OnErrorStoredProcedure] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsAuto] [bit] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AuditActionDate] [datetime] NOT NULL CONSTRAINT [DF_AuditTaskStep_AuditActionDate]  DEFAULT (getdate()),
	[AuditActionUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AuditTaskStep_AuditActionUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
