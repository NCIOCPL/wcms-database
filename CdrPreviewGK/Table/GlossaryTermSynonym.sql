SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GlossaryTermSynonym]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[GlossaryTermSynonym](
	[GlossaryTermSynonymID] [int] IDENTITY(1,1) NOT NULL,
	[GlossaryTermID] [int] NOT NULL,
	[TermName] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Synonym] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[GlossaryTermSynonymID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[GlossaryTermSynonym] TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GlossaryTermSynonym] ([GlossaryTermSynonymID]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GlossaryTermSynonym] ([GlossaryTermID]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GlossaryTermSynonym] ([TermName]) TO [webSiteUser_role]
GO
GRANT SELECT ON [dbo].[GlossaryTermSynonym] ([Synonym]) TO [webSiteUser_role]
GO
