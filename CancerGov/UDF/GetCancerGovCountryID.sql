IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovCountryID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovCountryID]
GO

/*
Function translate PDQ CountryID in to  CancerGov CountryID bace on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovCountryID( @PDQCountryID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	CountryID
		FROM 		dbo.Country
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQCountryID
	)
END



GO
