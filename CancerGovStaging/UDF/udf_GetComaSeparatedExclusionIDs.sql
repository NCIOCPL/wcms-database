IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetComaSeparatedExclusionIDs]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetComaSeparatedExclusionIDs]
GO
CREATE FUNCTION dbo.udf_GetComaSeparatedExclusionIDs
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
	FROM 	CancerGov.dbo.udf_GetComaSeparatedExclusionIDs (@ComaSeparatedID )

	RETURN 
END





GO
