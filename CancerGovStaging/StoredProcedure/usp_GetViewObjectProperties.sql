IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetViewObjectProperties]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetViewObjectProperties]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetViewObjectProperties 
	(
	@ViewObjectID		uniqueidentifier,
	@PropertyName		varchar(100) = NULL
	)	

AS

BEGIN

SELECT @PropertyName = NULLIF(@PropertyName, '')

IF @PropertyName IS NULL
BEGIN
	SELECT PropertyName, PropertyValue
	FROM ViewObjectProperty
	WHERE NCIViewObjectID = @ViewObjectID
END
ELSE
BEGIN
	SELECT PropertyName, PropertyValue
	FROM ViewObjectProperty
	WHERE NCIViewObjectID = @ViewObjectID
		AND PropertyName = @PropertyName
END

END
GO
GRANT EXECUTE ON [dbo].[usp_GetViewObjectProperties] TO [websiteuser_role]
GO
