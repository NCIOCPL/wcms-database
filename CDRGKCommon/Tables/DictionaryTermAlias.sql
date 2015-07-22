SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DictionaryTermAlias]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[DictionaryTermAlias](
	[TermID] [int] NOT NULL,
	[Othername] [nvarchar](1000) NOT NULL,
	[OtherNameType] [nvarchar](30) NOT NULL,
	[Language] [nvarchar](20) NOT NULL
) ON [PRIMARY]

END
GO

SET ANSI_PADDING ON
GO
