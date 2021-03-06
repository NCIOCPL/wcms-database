SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TaskStepArgument]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TaskStepArgument](
	[StepID] [uniqueidentifier] NOT NULL,
	[ArgumentOrdinal] [int] NOT NULL CONSTRAINT [DF_TaskStepArgument_ArgumentOrdinal]  DEFAULT (1),
	[ForProcedureX] [int] NOT NULL CONSTRAINT [DF_TaskStepArgument_ForProcedureX]  DEFAULT (1),
	[ArgumentValue] [varchar](3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_TaskStepArgument_UpdateDate_1]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TaskStepArgument_UpdateUserID_1]  DEFAULT (user_name()),
 CONSTRAINT [PK_TaskStepArgument] PRIMARY KEY CLUSTERED 
(
	[StepID] ASC,
	[ArgumentOrdinal] ASC,
	[ForProcedureX] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TaskStepArgument]') AND name = N'IX_TaskStepArgument_StepID')
CREATE NONCLUSTERED INDEX [IX_TaskStepArgument_StepID] ON [dbo].[TaskStepArgument] 
(
	[StepID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TaskStepArgument_TaskStep]') AND type = 'F')
ALTER TABLE [dbo].[TaskStepArgument]  WITH NOCHECK ADD  CONSTRAINT [FK_TaskStepArgument_TaskStep] FOREIGN KEY([StepID])
REFERENCES [TaskStep] ([StepID])
GO
ALTER TABLE [dbo].[TaskStepArgument] CHECK CONSTRAINT [FK_TaskStepArgument_TaskStep]
GO
