IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[GetCancerGovBasicTypeID]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[GetCancerGovBasicTypeID]
GO
CREATE FUNCTION dbo.GetCancerGovBasicTypeID()
RETURNS uniqueidentifier 
AS  

BEGIN 
	RETURN(
		SELECT CancerGov.dbo.GetCancerGovBasicTypeID()
	)
END



GO
