IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovTermID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovTermID]
GO

/*
Function translate PDQ TermID in to  CancerGov TermID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovTermID( @PDQTermID int )
RETURNS uniqueidentifier 
 
AS  

BEGIN 
	RETURN(
		SELECT 	TermID 
		FROM 		dbo.Terminology
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQTermID
	)
END







GO
