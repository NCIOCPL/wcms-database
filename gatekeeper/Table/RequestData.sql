SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RequestData]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RequestData](
	[RequestDataID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[PacketNumber] [int] NOT NULL,
	[ActionType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataSetID] [int] NULL,
	[CDRID] [int] NULL,
	[CDRVersion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReceivedDate] [datetime] NULL DEFAULT (getdate()),
	[Status] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DependencyStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Location] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[groupID] [int] NULL,
	[isArchived] [bit] NOT NULL DEFAULT ((0)),
 CONSTRAINT [PK__RequestData__66603565] PRIMARY KEY CLUSTERED 
(
	[RequestDataID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RequestData]') AND name = N'IX_RequestData_RequestID_UnitOfWorkID')
CREATE NONCLUSTERED INDEX [IX_RequestData_RequestID_UnitOfWorkID] ON [dbo].[RequestData] 
(
	[RequestID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RequestData]') AND name = N'NC_requestdata')
CREATE NONCLUSTERED INDEX [NC_requestdata] ON [dbo].[RequestData] 
(
	[groupID] ASC,
	[RequestID] ASC
)
INCLUDE ( [DependencyStatus]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[RequestData]') AND name = N'NC_requestdata_CDRID')
CREATE NONCLUSTERED INDEX [NC_requestdata_CDRID] ON [dbo].[RequestData] 
(
	[CDRID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Requestdata_request]') AND parent_object_id = OBJECT_ID(N'[dbo].[RequestData]'))
ALTER TABLE [dbo].[RequestData]  WITH CHECK ADD  CONSTRAINT [FK_Requestdata_request] FOREIGN KEY([RequestID])
REFERENCES [Request] ([RequestID])
GO
ALTER TABLE [dbo].[RequestData] CHECK CONSTRAINT [FK_Requestdata_request]
GO
