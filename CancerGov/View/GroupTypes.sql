IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GroupTypes]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[GroupTypes]
GO

CREATE VIEW [dbo].[GroupTypes]
AS

SELECT 	typeID,
	typeName,
	UpdateDate,
	UpdateUserID
FROM  	[CancerGovStaging].[dbo].[GroupTypes]

GO
