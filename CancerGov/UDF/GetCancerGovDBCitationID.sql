IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovDBCitationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovDBCitationID]
GO

/*
Function translate PDQ DatabaseCitationID in to  CancerGov DatabaseCitationID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovDBCitationID( @PDQDBCitationID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	DatabaseCitationID
		FROM 		dbo.DatabaseCitation
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQDBCitationID
	)
END




GO
