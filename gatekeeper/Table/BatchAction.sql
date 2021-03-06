SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BatchAction]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BatchAction](
	[BatchID] [int] NOT NULL,
	[ProcessActionID] [int] NOT NULL,
	[CompletionDate] [datetime] NULL,
 CONSTRAINT [BatchAction_PK] PRIMARY KEY CLUSTERED 
(
	[BatchID] ASC,
	[ProcessActionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Batch_BatchAction_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[BatchAction]'))
ALTER TABLE [dbo].[BatchAction]  WITH CHECK ADD  CONSTRAINT [Batch_BatchAction_FK1] FOREIGN KEY([BatchID])
REFERENCES [Batch] ([BatchID])
GO
ALTER TABLE [dbo].[BatchAction] CHECK CONSTRAINT [Batch_BatchAction_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[ProcessAction_BatchAction_FK1]') AND parent_object_id = OBJECT_ID(N'[dbo].[BatchAction]'))
ALTER TABLE [dbo].[BatchAction]  WITH CHECK ADD  CONSTRAINT [ProcessAction_BatchAction_FK1] FOREIGN KEY([ProcessActionID])
REFERENCES [ProcessAction] ([ProcessActionID])
GO
ALTER TABLE [dbo].[BatchAction] CHECK CONSTRAINT [ProcessAction_BatchAction_FK1]
GO
