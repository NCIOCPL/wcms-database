SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenericModule]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GenericModule](
	[GenericModuleID] [uniqueidentifier] NOT NULL,
	[Namespace] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[category] [int] NOT NULL,
	[moduleClass] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EditNamespace] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EditModuleClass] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AssemblyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsVirtual] [bit] NULL,
	[EditAssemblyName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_GenericModules] PRIMARY KEY CLUSTERED 
(
	[GenericModuleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
