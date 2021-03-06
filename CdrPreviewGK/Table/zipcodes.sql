SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[zipcodes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[zipcodes](
	[LATITUDE] [float] NULL,
	[ZipCode] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StateShortName] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountyName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LONGITUDE] [float] NULL,
	[CityName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_zipcodes] PRIMARY KEY CLUSTERED 
(
	[ZipCode] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
