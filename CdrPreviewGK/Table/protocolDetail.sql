SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[protocolDetail]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[protocolDetail](
	[protocolid] [int] NOT NULL,
	[HealthProfessionalTitle] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PatientTitle] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LowAge] [tinyint] NULL,
	[HighAge] [tinyint] NULL,
	[AgeRange] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsPatientVersionExists] [bit] NOT NULL CONSTRAINT [DF__protocolD__IsPatient]  DEFAULT (1),
	[PrimaryProtocolID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isCTprotocol] [bit] NOT NULL CONSTRAINT [DF__protocolD__isCTprotocol]  DEFAULT (0),
	[DateFirstPublished] [datetime] NULL,
	[DateLastModified] [datetime] NULL,
	[CurrentStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AlternateProtocolIDs] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Phase] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[updatedate] [datetime] NULL CONSTRAINT [DF__protocolD__updatedate]  DEFAULT (getdate()),
	[updateUserid] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__protocolD__updateUserid]  DEFAULT (suser_sname()),
	[typeofTrial] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sponsorofTrial] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_protocolDetail] PRIMARY KEY CLUSTERED 
(
	[protocolid] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_protocoldetail_Protocol]') AND type = 'F')
ALTER TABLE [dbo].[protocolDetail]  WITH CHECK ADD  CONSTRAINT [FK_protocoldetail_Protocol] FOREIGN KEY([protocolid])
REFERENCES [Protocol] ([protocolid])
GO
ALTER TABLE [dbo].[protocolDetail] CHECK CONSTRAINT [FK_protocoldetail_Protocol]
GO
