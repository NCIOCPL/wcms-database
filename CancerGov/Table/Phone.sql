SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Phone]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[Phone](
	[OwnerID] [uniqueidentifier] NOT NULL,
	[OwnerType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Type] [uniqueidentifier] NOT NULL,
	[Number] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[UsageOrder] [int] NULL CONSTRAINT [DF_Phone_UsageOrder]  DEFAULT (1),
	[DataSource] [char](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[FK_Phone_Type]') AND type = 'F')
ALTER TABLE [dbo].[Phone]  WITH CHECK ADD  CONSTRAINT [FK_Phone_Type] FOREIGN KEY([Type])
REFERENCES [Type] ([TypeID])
GO
ALTER TABLE [dbo].[Phone] CHECK CONSTRAINT [FK_Phone_Type]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[CK_PhoneOwnerType]') AND type = 'C')
ALTER TABLE [dbo].[Phone]  WITH NOCHECK ADD  CONSTRAINT [CK_PhoneOwnerType] CHECK  (([OwnerType] = 'PERSON_DIRECT_AFFILIATION_PHONE' or [OwnerType] = 'PERSON_HOME_PHONE' or [OwnerType] = 'ORGANIZATION_PHONE'))
GO
ALTER TABLE [dbo].[Phone] CHECK CONSTRAINT [CK_PhoneOwnerType]
GO
