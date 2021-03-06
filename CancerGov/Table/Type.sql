SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Type]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Type](
	[TypeID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Type_TypeID]  DEFAULT (newid()),
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Scope] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Type_Scope]  DEFAULT ('GENERIC'),
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Type_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Type_UpdateUser]  DEFAULT (user_name()),
	[SourceID] [numeric](18, 0) NULL,
	[DataSource] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_type] PRIMARY KEY NONCLUSTERED 
(
	[TypeID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Type]') AND name = N'Type1')
CREATE CLUSTERED INDEX [Type1] ON [dbo].[Type] 
(
	[SourceID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[Type]') AND name = N'IX_Type_SourceID_DataSource')
CREATE NONCLUSTERED INDEX [IX_Type_SourceID_DataSource] ON [dbo].[Type] 
(
	[SourceID] ASC,
	[DataSource] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
