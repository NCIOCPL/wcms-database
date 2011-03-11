IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetExternalObjects]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetExternalObjects]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetExternalObjects
	(
	@ViewId uniqueidentifier,
	@Type	char(10)
	)
AS
BEGIN
	SELECT ExternalObjectID,
		Format, 
		Description,
		Path,
		Text,
		dbo.udf_GetViewObjectPrettyUrl(vo.NCIViewID, vo.ObjectID) AS PrettyUrl
	FROM ViewObjects vo, ExternalObject eo
	WHERE vo.NCIViewID = @ViewId
		AND Type = @Type
		AND vo.ObjectID = eo.ExternalObjectID
		AND Path IS NOT NULL
	ORDER BY Priority
END
GO
