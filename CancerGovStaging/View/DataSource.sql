IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DataSource]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[DataSource]
GO

/****** Object:  VIEW [dbo].[DataSource]    Script Date: 10/8/2001 11:57:34 PM ******/
CREATE VIEW [dbo].[DataSource] AS 
SELECT 
	[DataSourceID]  ,
	[Name]  ,
	[Description],
	[UpdateDate]  ,
	[UpdateUserID]  
FROM CancerGov..[DataSource] 

GO
