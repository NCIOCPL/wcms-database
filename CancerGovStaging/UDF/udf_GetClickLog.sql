IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetClickLog]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetClickLog]
GO
CREATE FUNCTION dbo.udf_GetClickLog
	(
		@NCIViewId	uniqueidentifier
	)

RETURNS varchar(10)

AS


BEGIN 

             DECLARE @value varchar(200)
             
	SELECT @value = (SELECT propertyvalue 
			FROM viewproperty 
			WHERE NCIViewId = @NCIViewId 
			AND propertyname = 'Clicklogging')

              IF @value IS Null
                 SELECT @value = 'No'

              return @value
END


GO
