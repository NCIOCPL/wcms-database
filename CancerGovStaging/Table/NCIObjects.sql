SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCIObjects]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NCIObjects](
	[ObjectInstanceID] [uniqueidentifier] NOT NULL,
	[NCIObjectID] [uniqueidentifier] NOT NULL,
	[ParentNCIObjectID] [uniqueidentifier] NULL,
	[ObjectType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Priority] [int] NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
