SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LiteratureCitationAuthor]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LiteratureCitationAuthor](
	[LiteratureCitationID] [uniqueidentifier] NOT NULL,
	[AuthorType] [uniqueidentifier] NOT NULL,
	[AuthorID] [uniqueidentifier] NOT NULL,
	[SequenceNumber] [int] NOT NULL CONSTRAINT [DF_LiteratureCitationAuthor_SequenceNumber_1]  DEFAULT (1),
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF_LiteratureCitationAuthor_UpdateDate_1]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LiteratureCitationAuthor_UpdateUserID_1]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_LiteratureCitationAuthor_LiteratureCitation]') AND type = 'F')
ALTER TABLE [dbo].[LiteratureCitationAuthor]  WITH CHECK ADD  CONSTRAINT [FK_LiteratureCitationAuthor_LiteratureCitation] FOREIGN KEY([LiteratureCitationID])
REFERENCES [LiteratureCitation] ([LiteratureCitationID])
GO
ALTER TABLE [dbo].[LiteratureCitationAuthor] CHECK CONSTRAINT [FK_LiteratureCitationAuthor_LiteratureCitation]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_LiteratureCitationAuthor_Type]') AND type = 'F')
ALTER TABLE [dbo].[LiteratureCitationAuthor]  WITH CHECK ADD  CONSTRAINT [FK_LiteratureCitationAuthor_Type] FOREIGN KEY([AuthorType])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[LiteratureCitationAuthor] CHECK CONSTRAINT [FK_LiteratureCitationAuthor_Type]
GO
