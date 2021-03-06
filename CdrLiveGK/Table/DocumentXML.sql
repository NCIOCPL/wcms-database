SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DocumentXML]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[DocumentXML](
	[documentid] [int] NOT NULL,
	[xml] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updateuserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT (suser_sname()),
	[updateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_DocumentXML] PRIMARY KEY CLUSTERED 
(
	[documentid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
