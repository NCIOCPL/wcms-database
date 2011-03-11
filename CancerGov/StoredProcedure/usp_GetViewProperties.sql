IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewProperties]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewProperties]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetViewProperties 
	(
	@ViewID		uniqueidentifier,
	@PropertyName		varchar(100) = NULL
	)	

AS

BEGIN

SELECT @PropertyName = NULLIF(@PropertyName, '')

IF @PropertyName IS NULL
BEGIN
	SELECT PropertyName, PropertyValue
	FROM ViewProperty
	WHERE NCIViewID = @ViewID
END
ELSE
BEGIN
	SELECT PropertyName, PropertyValue
	FROM ViewProperty
	WHERE NCIViewID = @ViewID
		AND PropertyName = @PropertyName
END

END
GO
GRANT EXECUTE ON [dbo].[usp_GetViewProperties] TO [websiteuser_role]
GO
