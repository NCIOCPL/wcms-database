SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GenericModuleStyleSheetMap]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GenericModuleStyleSheetMap](
	[GenericModuleID] [uniqueidentifier] NOT NULL,
	[StyleSheetID] [uniqueidentifier] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_GenericModuleCSSMap] PRIMARY KEY CLUSTERED 
(
	[GenericModuleID] ASC,
	[StyleSheetID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_GenericModuleCSSMap_CSS]') AND parent_object_id = OBJECT_ID(N'[dbo].[GenericModuleStyleSheetMap]'))
ALTER TABLE [dbo].[GenericModuleStyleSheetMap]  WITH CHECK ADD  CONSTRAINT [FK_GenericModuleCSSMap_CSS] FOREIGN KEY([StyleSheetID])
REFERENCES [ModuleStyleSheet] ([StyleSheetID])
GO
ALTER TABLE [dbo].[GenericModuleStyleSheetMap] CHECK CONSTRAINT [FK_GenericModuleCSSMap_CSS]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_GenericModuleCSSMap_GenericModules]') AND parent_object_id = OBJECT_ID(N'[dbo].[GenericModuleStyleSheetMap]'))
ALTER TABLE [dbo].[GenericModuleStyleSheetMap]  WITH CHECK ADD  CONSTRAINT [FK_GenericModuleCSSMap_GenericModules] FOREIGN KEY([GenericModuleID])
REFERENCES [GenericModule] ([GenericModuleID])
GO
ALTER TABLE [dbo].[GenericModuleStyleSheetMap] CHECK CONSTRAINT [FK_GenericModuleCSSMap_GenericModules]
GO
