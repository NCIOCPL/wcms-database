SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[ProtocolSearch]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[ProtocolSearch](
	[ProtocolSearchID] [int] IDENTITY(1,1) NOT NULL,
	[SearchDate] [datetime] NOT NULL CONSTRAINT [DF_ProtocolSearch_SearchDate]  DEFAULT (getdate()),
	[CancerType] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CancerTypeStage] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TrialType] [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TrialStatus] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AlternateProtocolID] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ZIP] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ZIPProximity] [int] NULL,
	[City] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[State] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Country] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Institution] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Investigator] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LeadOrganization] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VAMilitaryOrganization] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsNIHClinicalCenterTrial] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsNew] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TreatmentType] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Drug] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Phase] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TrialSponsor] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AbstractVersion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterOne] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterTwo] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParameterThree] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ShowDetailReportMessage] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CanBeDeleted] [bit] NULL CONSTRAINT [DF_ProtocolSearch_CanBeDeleted]  DEFAULT (1),
	[IsCachedSearchResultAvailable] [bit] NULL CONSTRAINT [DF_ProtocolSearch_IsCachedSearchResultAvailable]  DEFAULT (0),
	[Requested] [int] NOT NULL CONSTRAINT [DF_ProtocolSearch_Requested]  DEFAULT (0),
	[IsCachedContactsAvailable] [bit] NULL CONSTRAINT [DF_ProtocolSearch_IsCachedContactsAvailable]  DEFAULT (0),
	[DrugSearchFormula] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SearchType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DisplayHeader] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[specialCategory] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InstitutionID] [varchar](1200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InvestigatorID] [varchar](600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LeadOrganizationID] [varchar](700) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DrugID] [varchar](1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IDstring] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isLink] [bit] NULL,
	[idstringHash] [int] NULL,
	keyword nvarchar(500),
	treatmentTypeName varchar(max),
 CONSTRAINT [PK_ProtocolSearch] PRIMARY KEY CLUSTERED 
(
	[ProtocolSearchID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolSearch]') AND name = N'IX_ProtocolSearch_IsCachedSearchResultAvailable')
CREATE NONCLUSTERED INDEX [IX_ProtocolSearch_IsCachedSearchResultAvailable] ON [dbo].[ProtocolSearch] 
(
	[IsCachedSearchResultAvailable] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[ProtocolSearch]') AND name = N'NCI_protocolsearch_idstringHash')
CREATE NONCLUSTERED INDEX [NCI_protocolsearch_idstringHash] ON [dbo].[ProtocolSearch] 
(
	[idstringHash] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
