SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCITemplate]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NCITemplate](
	[NCITemplateID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_NCITemplate_NCITemplateID]  DEFAULT (newid()),
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[URL] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_NCITemplate_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_NCITemplate_UpdateUserID]  DEFAULT (user_name()),
	[AddURL] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EditURL] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isnew] [bit] NULL DEFAULT (0),
	[ClassName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_NCITemplate] PRIMARY KEY CLUSTERED 
(
	[NCITemplateID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[NCITemplate] TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([NCITemplateID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([Name]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([URL]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([Description]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([UpdateDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([UpdateUserID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([AddURL]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([EditURL]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([isnew]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[NCITemplate] ([ClassName]) TO [webadminuser_role]
GO
