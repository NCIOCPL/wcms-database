SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODModule]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODModule](
	[ModuleID] [uniqueidentifier] NOT NULL,
	[ModuleName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[GenericModuleID] [uniqueidentifier] NOT NULL,
	[CSSID] [uniqueidentifier] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_PRODModules] PRIMARY KEY CLUSTERED 
(
	[ModuleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODModules_GenericModules]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODModule]'))
ALTER TABLE [dbo].[PRODModule]  WITH CHECK ADD  CONSTRAINT [FK_PRODModules_GenericModules] FOREIGN KEY([GenericModuleID])
REFERENCES [GenericModule] ([GenericModuleID])
GO
ALTER TABLE [dbo].[PRODModule] CHECK CONSTRAINT [FK_PRODModules_GenericModules]
GO
