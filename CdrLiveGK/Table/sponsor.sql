SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sponsor]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[sponsor](
	[sponsorid] [tinyint] NOT NULL,
	[sponsorName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF__sponsor__updatedate]  DEFAULT (getdate()),
	[updateuserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__sponsor__updateuserid]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_sponsor] PRIMARY KEY CLUSTERED 
(
	[sponsorid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
