SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[studycategory]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[studycategory](
	[studycategoryid] [tinyint] IDENTITY(1,1) NOT NULL,
	[studycategoryname] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF__studycate__updatedate]  DEFAULT (getdate()),
	[updateuserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__studycate__updateUserid]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_studycategory] PRIMARY KEY CLUSTERED 
(
	[studycategoryid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
