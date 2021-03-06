SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PrettyURLFlag]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[PrettyURLFlag](
	[NeedUpdate] [bit] NULL CONSTRAINT [DF_PrettyURLFlag_NeedUpdate]  DEFAULT (0),
	[InProgress] [bit] NULL CONSTRAINT [DF_PrettyURLFlag_InProgress]  DEFAULT (0),
	[LastStartTime] [datetime] NULL CONSTRAINT [DF_PrettyURLFlag_LastStartDate]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
GRANT SELECT ON [dbo].[PrettyURLFlag] TO [prettyurluser_role]
GO
GRANT UPDATE ON [dbo].[PrettyURLFlag] TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURLFlag] ([NeedUpdate]) TO [prettyurluser_role]
GO
GRANT UPDATE ON [dbo].[PrettyURLFlag] ([NeedUpdate]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURLFlag] ([InProgress]) TO [prettyurluser_role]
GO
GRANT UPDATE ON [dbo].[PrettyURLFlag] ([InProgress]) TO [prettyurluser_role]
GO
GRANT SELECT ON [dbo].[PrettyURLFlag] ([LastStartTime]) TO [prettyurluser_role]
GO
GRANT UPDATE ON [dbo].[PrettyURLFlag] ([LastStartTime]) TO [prettyurluser_role]
GO
