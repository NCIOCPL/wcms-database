IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovProtocolID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovProtocolID]
GO

/*
Function translate PDQ ProtocolID in to  CancerGov ProtocolID base on the data in database.
*/
CREATE FUNCTION dbo.GetCancerGovProtocolID( @PDQProtocolID int )
RETURNS uniqueidentifier 
 
AS  

BEGIN 
	RETURN(
		SELECT 	ProtocolID 
		FROM 		dbo.Protocol
		 WHERE 	DataSource = dbo.GetPDQDataSourceID()
				AND SourceID = @PDQProtocolID
	)
END






GO
