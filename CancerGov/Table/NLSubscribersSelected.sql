SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NLSubscribersSelected]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NLSubscribersSelected](
	[DateSelected] [datetime] NULL,
	[NumberSelected] [int] NULL
) ON [PRIMARY]
END
GO
