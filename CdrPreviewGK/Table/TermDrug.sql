SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermDrug]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermDrug](
	[TermID] [int] NOT NULL,
	[DrugName] [nvarchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DisplayName] [nvarchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermDrug]') AND name = N'CI_TermDrug')
CREATE CLUSTERED INDEX [CI_TermDrug] ON [dbo].[TermDrug] 
(
	[DrugName] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
