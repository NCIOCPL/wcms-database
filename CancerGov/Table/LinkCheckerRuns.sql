SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkCheckerRuns](
	[RunID] [uniqueidentifier] NOT NULL,
	[StatusDate] [datetime] NULL,
 CONSTRAINT [PK_LinkCheckerRuns] PRIMARY KEY CLUSTERED 
(
	[RunID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
