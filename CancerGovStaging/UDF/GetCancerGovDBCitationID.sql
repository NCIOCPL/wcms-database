IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovDBCitationID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovDBCitationID]
GO
CREATE FUNCTION dbo.GetCancerGovDBCitationID( @PDQDBCitationID int )
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT  CancerGov.dbo.GetCancerGovDBCitationID( @PDQDBCitationID )
	)
END




GO
