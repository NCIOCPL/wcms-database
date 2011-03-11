IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovAffiliationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovAffiliationID]
GO
/*
Function translate PDQ Person Affiliation ID in to  CancerGov Affiliation ID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovAffiliationID( @PDQAffiliationID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	TOP  1 
				AffiliationID 
		FROM 		dbo.Affiliation
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQAffiliationID
	)
END









GO
