SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Top10History]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Top10History](
	[id] [int] NULL,
	[duration] [numeric](10, 0) NULL,
	[idstring] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pOne] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[pTwo] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[starttime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
