IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovPersonID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovPersonID]
GO
/*
Function translate PDQ PersonID in to  CancerGov PersonID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovPersonID( @PDQPersonID int )
RETURNS uniqueidentifier 
WITH SCHEMABINDING
AS  

BEGIN 
	RETURN(
		SELECT 	TOP 1
				PersonID 
		FROM 		dbo.Person
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQPersonID
	)
END








GO
