SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[redirectmap_BKU_20040319101939]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[redirectmap_BKU_20040319101939](
	[map_id] [uniqueidentifier] NOT NULL,
	[OldURL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CurrentURL] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Source] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UpdateDate] [datetime] NULL
) ON [PRIMARY]
END
GO
