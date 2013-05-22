IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProtocolByCancerType]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProtocolByCancerType]
GO

CREATE FUNCTION [dbo].[udf_GetProtocolByCancerType] 
	( 
	@PDQCancerType varchar(200), 
	@IsActiveProtocol varchar(1),
	@ReturnExcluded char(1) = 'N'
	)  
RETURNS @ResultTable TABLE
	(
	ProtocolID	uniqueidentifier 
	)
AS  

BEGIN 
	INSERT INTO @ResultTable 
	SELECT ProtocolID	
	FROM CancerGov.dbo.udf_GetProtocolByCancerType(@PDQCancerType , @IsActiveProtocol, @ReturnExcluded ) 
	RETURN
END










GO
