IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetComaSeparatedInclusionIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetComaSeparatedInclusionIDs]
GO
CREATE FUNCTION dbo.udf_GetComaSeparatedInclusionIDs
	(
	@ComaSeparatedID varchar(8000)
	)
RETURNS @ResultTable TABLE
	(
	ObjectID     varchar(40)
	)
AS

BEGIN
	INSERT INTO @ResultTable 
	SELECT ObjectID    
	FROM 	CancerGov.dbo.udf_GetComaSeparatedInclusionIDs (@ComaSeparatedID )

	RETURN 
END



GO
