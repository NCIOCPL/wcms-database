CREATE TABLE [dbo].[GeneralComments](
	[CommentID] [uniqueidentifier] NOT NULL,
	[Comment] nvarchar(max) NOT NULL,
	[CommentDate] [datetime] NULL CONSTRAINT [DF_DCComments_CommentDate]  DEFAULT (getdate()),
	[CommentType] [varchar](50) NULL CONSTRAINT [DF_DCComments_CommentType]  DEFAULT ('DC'),
 CONSTRAINT [PK_DCComments] PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 30) ON [PRIMARY]
) ON [PRIMARY]

GO


