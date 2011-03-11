IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovCitationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovCitationID]
GO
/*
Function translate PDQ CitationID in to  CancerGov CitationID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovCitationID( @PDQCitationID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	TOP 1
				CitationID
		FROM 		dbo.Citation
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQCitationID
	)
END




GO
