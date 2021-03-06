SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ClickLogHistory]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ClickLogHistory](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[EventSrc] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DestUrl] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClientIP] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UserSessionID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClickItem] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateLogged] [datetime] NULL
) ON [PRIMARY]
END
GO
