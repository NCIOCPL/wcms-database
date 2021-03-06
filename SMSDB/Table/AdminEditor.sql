SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AdminEditor]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AdminEditor](
	[AdminEditorID] [uniqueidentifier] NOT NULL,
	[AssemblyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Namespace] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AdminEditorClass] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_AdminEditor] PRIMARY KEY CLUSTERED 
(
	[AdminEditorID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
