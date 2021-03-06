SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HotFixProtocolStudyContact]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[HotFixProtocolStudyContact](
	[ProtocolID] [uniqueidentifier] NOT NULL,
	[PersonID] [uniqueidentifier] NOT NULL,
	[OrganizationID] [uniqueidentifier] NOT NULL,
	[CountryID] [uniqueidentifier] NULL,
	[StateID] [uniqueidentifier] NULL,
	[Country] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[State] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[City] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrganizationName] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PersonName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PhoneNumber] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrgInfo] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UpdateDate] [datetime] NULL DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL DEFAULT ('(getuserID())'),
	[IsApproved] [bit] NULL DEFAULT (0)
) ON [PRIMARY]
END
GO
