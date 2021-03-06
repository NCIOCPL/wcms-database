SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PRODZoneInstance]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PRODZoneInstance](
	[ZoneInstanceID] [uniqueidentifier] NOT NULL,
	[NodeID] [uniqueidentifier] NOT NULL,
	[CanInherit] [bit] NULL,
	[TemplateZoneID] [uniqueidentifier] NOT NULL,
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_PRODZoneInstances] PRIMARY KEY CLUSTERED 
(
	[ZoneInstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [UQ_PRODZoneInstance_NodeZone] UNIQUE NONCLUSTERED 
(
	[NodeID] ASC,
	[TemplateZoneID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODZoneInstance_NodeID]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODZoneInstance]'))
ALTER TABLE [dbo].[PRODZoneInstance]  WITH CHECK ADD  CONSTRAINT [FK_PRODZoneInstance_NodeID] FOREIGN KEY([NodeID])
REFERENCES [PRODNode] ([NodeID])
GO
ALTER TABLE [dbo].[PRODZoneInstance] CHECK CONSTRAINT [FK_PRODZoneInstance_NodeID]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_PRODZoneInstance_TemplateZoneID]') AND parent_object_id = OBJECT_ID(N'[dbo].[PRODZoneInstance]'))
ALTER TABLE [dbo].[PRODZoneInstance]  WITH CHECK ADD  CONSTRAINT [FK_PRODZoneInstance_TemplateZoneID] FOREIGN KEY([TemplateZoneID])
REFERENCES [TemplateZone] ([TemplateZoneID])
GO
ALTER TABLE [dbo].[PRODZoneInstance] CHECK CONSTRAINT [FK_PRODZoneInstance_TemplateZoneID]
GO
