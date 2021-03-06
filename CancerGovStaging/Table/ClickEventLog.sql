SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ClickEventLog]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ClickEventLog](
	[EventID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ClickEventLog_EventID]  DEFAULT (newid()),
	[EventSrc] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DestUrl] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ClickItem] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateLogged] [datetime] NULL CONSTRAINT [DF_ClickEventLog_DateLogged]  DEFAULT (getdate()),
 CONSTRAINT [PK_ClickEventLog] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
