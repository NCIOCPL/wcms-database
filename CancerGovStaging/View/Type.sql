IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Type]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[Type]
GO

/****** Object:  VIEW [dbo].[Type]    Script Date: 10/8/2001 11:57:36 PM ******/
CREATE VIEW [dbo].[Type] AS 
SELECT 
	[TypeID],
	[Name],
	[ShortName],
	[Description],
	[Scope]  ,
	[UpdateDate]  ,
	[UpdateUserID]  ,
	[SourceID]  ,
	[DataSource]  
FROM CancerGov..[Type]

GO
