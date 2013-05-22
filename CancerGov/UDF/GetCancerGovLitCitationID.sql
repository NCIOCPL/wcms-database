IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovLitCitationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovLitCitationID]
GO

/*
Function translate PDQ LiteratureCitationID in to  CancerGov LiteratureCitationID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovLitCitationID( @PDQLitCitationID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	LiteratureCitationID
		FROM 		dbo.LiteratureCitation
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQLitCitationID
	)
END





GO
