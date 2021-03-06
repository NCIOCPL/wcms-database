SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[modality]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[modality](
	[modalityid] [int] NOT NULL,
	[modalityname] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF__modality__updatedate]  DEFAULT (getdate()),
	[updateuserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__modality__updateUserid]  DEFAULT (suser_sname()),
 CONSTRAINT [PK_modality] PRIMARY KEY CLUSTERED 
(
	[modalityid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
