SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GenProfAreasOfSpecialization]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[GenProfAreasOfSpecialization](
	[GenProfID] [int] NULL,
	[Syndrome] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CancerType] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CancerSite] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CancerTypeSiteID] [int] NULL,
	[UpdateDate] [datetime] NOT NULL CONSTRAINT [DF__GenProfAr__Updat__1CFC3D38]  DEFAULT (getdate()),
	[UpdateUserID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__GenProfAr__Updat__1DF06171]  DEFAULT (user_name())
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[GenProfAreasOfSpecialization]') AND name = N'IX_GenProfAreasOfSpecialization')
CREATE CLUSTERED INDEX [IX_GenProfAreasOfSpecialization] ON [dbo].[GenProfAreasOfSpecialization] 
(
	[Syndrome] ASC,
	[CancerType] ASC,
	[CancerSite] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[GenProfAreasOfSpecialization]') AND name = N'GenProfAreasOfSpecialization5')
CREATE NONCLUSTERED INDEX [GenProfAreasOfSpecialization5] ON [dbo].[GenProfAreasOfSpecialization] 
(
	[GenProfID] ASC,
	[Syndrome] ASC,
	[CancerTypeSiteID] ASC
)WITH FILLFACTOR = 90 ON [PRIMARY]
GO
if not exists (select * from sysindexes si1, sysindexes si2 where si1.name = N'Statistic_CancerSite' and si2.name = N'GenProfAreasOfSpecialization' and si1.id = si2.id)
CREATE STATISTICS [Statistic_CancerSite] ON [dbo].[GenProfAreasOfSpecialization]([CancerSite])
GO
