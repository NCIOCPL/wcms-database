IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[NCISite]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[NCISite]
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE VIEW dbo.NCISite
AS

SELECT  NCISiteID, 
	[Name], 
	[Description]
	UpdateUserID, 
	UpdateDate
FROM	CancerGovStaging.dbo.NCISite


GO
