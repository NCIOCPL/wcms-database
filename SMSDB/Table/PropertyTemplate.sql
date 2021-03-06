SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PropertyTemplate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PropertyTemplate](
	[PropertyTemplateID] [uniqueidentifier] NOT NULL,
	[PropertyName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ValueType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefaultValue] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF_PropertyT_CreateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_PropertyT_UpdateDate]  DEFAULT (getdate()),
 CONSTRAINT [PK_PropertyTemplates] PRIMARY KEY CLUSTERED 
(
	[PropertyTemplateID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
