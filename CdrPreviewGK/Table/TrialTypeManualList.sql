SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TrialTypeManualList]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TrialTypeManualList](
	[displayName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[displayPosition] [tinyint] NULL,
	[typeID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
END
GO
