IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetViewObjectProperty]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetViewObjectProperty]
GO
CREATE FUNCTION dbo.udf_GetViewObjectProperty 
(
	@ObjectID		uniqueidentifier,
	@PropertyName		varchar(50)
)
  
RETURNS varchar (7800) 

AS  


BEGIN 

	RETURN (
		SELECT vop.PropertyValue 
		FROM ViewObjectProperty vop INNER JOIN ViewObjects vo ON vop.NCIViewObjectID = vo.NCIViewObjectID 
		WHERE vo.ObjectID = @ObjectID 
			AND PropertyName = @PropertyName
		)
 
END





GO
