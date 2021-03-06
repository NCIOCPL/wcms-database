SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FlashObjectParams]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[FlashObjectParams](
	[FlashObjectID] [uniqueidentifier] NULL,
	[FlashObjectParamID] [uniqueidentifier] NOT NULL,
	[ParamName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParamValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParamTypeID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateUserID] [varbinary](50) NULL,
 CONSTRAINT [PK_FlashObjectParams] PRIMARY KEY CLUSTERED 
(
	[FlashObjectParamID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
