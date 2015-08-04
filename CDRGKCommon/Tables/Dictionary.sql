SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Dictionary]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Dictionary](
	[TermID] [int] NOT NULL,
	[TermName] [nvarchar](1000) NOT NULL,
	[Dictionary] [nvarchar](10) NOT NULL,
	[Language] [nvarchar](20) NOT NULL,
	[Audience] [nvarchar](25) NOT NULL,
	[ApiVers] [nvarchar](10) NOT NULL,
	[Object] [nvarchar](max) NOT NULL
) ON [PRIMARY]

END
GO

SET ANSI_PADDING ON
GO
