SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HotFixProtocol]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[HotFixProtocol](
	[ProtocolID] [uniqueidentifier] NOT NULL,
	[Comments] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Title] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ShortTitle] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Abstract] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DosageForms] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DosageSchedule] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EndPoints] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EntryCriteria] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Objectives] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Outline] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProjectedAccrual] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SpeciaStudyParameters] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Stratification] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Warning] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreateDate] [datetime] NULL DEFAULT (getdate()),
	[CreateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('(getuserID())'),
	[UpdatedDate] [datetime] NULL DEFAULT (getdate()),
	[ApprovedDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('(getuserID())'),
	[IsApproved] [bit] NULL DEFAULT (0),
PRIMARY KEY CLUSTERED 
(
	[ProtocolID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
