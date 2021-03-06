SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TermOtherName]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[TermOtherName](
	[OtherNameID] [int] NOT NULL,
	[TermID] [int] NULL,
	[OtherName] [nvarchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OtherNameType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReviewStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Comment] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[TermOtherName]') AND name = N'CI_termothername')
CREATE CLUSTERED INDEX [CI_termothername] ON [dbo].[TermOtherName] 
(
	[TermID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_TermOtherName_terminology]') AND type = 'F')
ALTER TABLE [dbo].[TermOtherName]  WITH CHECK ADD  CONSTRAINT [FK_TermOtherName_terminology] FOREIGN KEY([TermID])
REFERENCES [Terminology] ([TermID])
GO
ALTER TABLE [dbo].[TermOtherName] CHECK CONSTRAINT [FK_TermOtherName_terminology]
GO
