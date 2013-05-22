IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetUrlToDisplay]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetUrlToDisplay]
GO
CREATE FUNCTION dbo.udf_GetUrlToDisplay
	(
		@NCIViewId	uniqueidentifier
	)

RETURNS varchar(200)

AS


BEGIN 

             DECLARE @PrettyUrl varchar(200)
             
	SELECT @PrettyUrl = (SELECT Top 1 CurrentUrl FROM PrettyUrl WHERE NCIViewId = @NCIViewId AND IsPrimary = 1 AND IsRoot = 1)

              IF @PrettyUrl IS NOT Null
                 return (@PrettyUrl)

              return (SELECT top 1 (URL + '?' + URLArguments) from NCIView where NCIViewId = @NCIViewId)
END

GO
