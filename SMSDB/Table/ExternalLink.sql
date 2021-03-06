SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExternalLink]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ExternalLink](
	[LinkID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ExternalLink_LinkID]  DEFAULT (newid()),
	[Title] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Url] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsExternal] [bit] NOT NULL CONSTRAINT [DF_ExternalLink_IsExternal]  DEFAULT ((0)),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF__ExternalL__Creat__54B68676]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF__ExternalL__Updat__55AAAAAF]  DEFAULT (getdate()),
	[OwnerID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ExternalLink] PRIMARY KEY CLUSTERED 
(
	[LinkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
