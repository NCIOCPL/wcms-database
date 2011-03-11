IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Organization]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Organization]
GO

/****** Object:  VIEW [dbo].[Organization]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[Organization] AS 
SELECT 
	[OrganizationID],
	[ParentOrganizationID]  ,
	[PrimaryType]  ,
	[Name],
	[ShortName]  ,
	[City]  ,
	[CitySuffix]  ,
	[StateID]  ,
	[CountryID]  ,
	[PostalCode]  ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Organization]

GO
