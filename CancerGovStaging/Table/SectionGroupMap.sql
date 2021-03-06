SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[SectionGroupMap]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[SectionGroupMap](
	[SectionID] [uniqueidentifier] NOT NULL,
	[GroupID] [int] NOT NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate())
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[SectionGroupMap] TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[SectionGroupMap] ([SectionID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[SectionGroupMap] ([GroupID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[SectionGroupMap] ([CreateDate]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[SectionGroupMap] ([UpdateUserID]) TO [webadminuser_role]
GO
GRANT SELECT ON [dbo].[SectionGroupMap] ([UpdateDate]) TO [webadminuser_role]
GO
