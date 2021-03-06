SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GeneticsProfessional]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[GeneticsProfessional](
	[ID] [int] NULL,
	[Note] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FirstName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Suffix] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Degree] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF__GeneticsP__Updat__2C3E80C8]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__GeneticsP__Updat__2D32A501]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
