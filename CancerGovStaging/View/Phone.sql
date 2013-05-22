IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Phone]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Phone]
GO

/****** Object:  VIEW [dbo].[Phone]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[Phone] AS 
SELECT 
	[OwnerID],
	[OwnerType]  ,
	[Type],
	[Number]  ,
	[UsageOrder]  ,
	[DataSource]  
FROM CancerGov..[Phone]

GO
