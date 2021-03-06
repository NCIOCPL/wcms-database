SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ListItem_BKU_20040319101938]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ListItem_BKU_20040319101938](
	[ListID] [uniqueidentifier] NOT NULL,
	[NCIViewID] [uniqueidentifier] NOT NULL,
	[Priority] [int] NOT NULL,
	[IsFeatured] [bit] NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
