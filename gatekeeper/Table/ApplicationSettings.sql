SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ApplicationSettings]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ApplicationSettings](
	[ApplicationSettingsID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Value] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [ApplicationSettings_PK] PRIMARY KEY CLUSTERED 
(
	[ApplicationSettingsID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
