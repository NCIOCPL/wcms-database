SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQCancerTypeStages]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[PDQCancerTypeStages](
	[PDQCancerType] [numeric](18, 0) NOT NULL,
	[StageID] [uniqueidentifier] NOT NULL,
	[Stage] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_PDQCancerTypeStages_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PDQCancerTypeStages_UpdateUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
