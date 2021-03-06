SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Image]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Image](
	[ImageID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Image_ImageID]  DEFAULT (newid()),
	[ImageName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ImageSource] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ImageAltText] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TextSource] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Url] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Width] [int] NULL,
	[Height] [int] NULL,
	[Border] [int] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_Image_UpdateDate1]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Image_UpdateUserID1]  DEFAULT (user_name()),
 CONSTRAINT [PK_Image] PRIMARY KEY CLUSTERED 
(
	[ImageID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
