SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PDQModalityTree]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[PDQModalityTree](
	[PDQModalityID] [numeric](18, 0) NOT NULL,
	[ModalityID] [uniqueidentifier] NOT NULL,
	[UpdateDate] [datetime] NULL CONSTRAINT [DF_PDQModalityTree_UpdateDate]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PDQModalityTree_UpdateUserID]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
