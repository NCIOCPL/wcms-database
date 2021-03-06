SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCIObjects]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[NCIObjects](
	[ObjectInstanceID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__NCIObject__Objec__7231DAC4]  DEFAULT (newid()),
	[NCIObjectID] [uniqueidentifier] NOT NULL,
	[ParentNCIObjectID] [uniqueidentifier] NULL,
	[ObjectType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Priority] [int] NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF__NCIObject__Updat__7325FEFD]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__NCIObject__Updat__741A2336]  DEFAULT (user_name()),
 CONSTRAINT [PK__NCIObjects_objectInstanceid] PRIMARY KEY NONCLUSTERED 
(
	[ObjectInstanceID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[NCIObjects]') AND name = N'IX_NCIObjects_ParentNCIObjectid')
CREATE CLUSTERED INDEX [IX_NCIObjects_ParentNCIObjectid] ON [dbo].[NCIObjects] 
(
	[ParentNCIObjectID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
