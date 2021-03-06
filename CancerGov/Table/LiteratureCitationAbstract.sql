SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LiteratureCitationAbstract]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LiteratureCitationAbstract](
	[LiteratureCitationID] [uniqueidentifier] NOT NULL,
	[Abstract] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_LiteratureCitationAbstract_UpdateDate_1]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LiteratureCitationAbstract_UpdateUserID_1]  DEFAULT (user_name())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_LiteratureCitationAbstract_LiteratureCitation]') AND type = 'F')
ALTER TABLE [dbo].[LiteratureCitationAbstract]  WITH CHECK ADD  CONSTRAINT [FK_LiteratureCitationAbstract_LiteratureCitation] FOREIGN KEY([LiteratureCitationID])
REFERENCES [LiteratureCitation] ([LiteratureCitationID])
GO
ALTER TABLE [dbo].[LiteratureCitationAbstract] CHECK CONSTRAINT [FK_LiteratureCitationAbstract_LiteratureCitation]
GO
