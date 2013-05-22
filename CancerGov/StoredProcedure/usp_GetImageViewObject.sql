IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetImageViewObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetImageViewObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE usp_GetImageViewObject
	(
	@ViewId	uniqueidentifier = null,
	@ImageName	varchar(200) = null
	)
AS
BEGIN

	IF @ViewId IS NOT NULL AND NULLIF(@ImageName, '') IS NOT NULL
	BEGIN
		SELECT vo.NCIViewID, i.ImageId, i.ImageName, i.ImageSource, i.ImageAltText, i.TextSource, i.Url, i.Width, i.Height, i.Border, vo.Priority,
		dbo.udf_GetViewObjectProperty(i.ImageID, 'Clicklogging') AS ClickloggingEnabled
		FROM ViewObjects vo INNER JOIN [Image] i ON vo.ObjectId = i.ImageId
		WHERE vo.NCIViewId = @ViewId AND i.ImageName = @ImageName
		ORDER BY vo.Priority
	END
	ELSE IF @ViewId IS NOT NULL
	BEGIN
		SELECT vo.NCIViewID, i.ImageId, i.ImageName, i.ImageSource, i.ImageAltText, i.TextSource, i.Url, i.Width, i.Height, i.Border, vo.Priority,
		dbo.udf_GetViewObjectProperty(i.ImageID, 'Clicklogging') AS ClickloggingEnabled
		FROM ViewObjects vo INNER JOIN [Image] i ON vo.ObjectId = i.ImageId
		WHERE vo.NCIViewId = @ViewId
		ORDER BY vo.Priority
	END
	ELSE IF NULLIF(@ImageName, '') IS NOT NULL
	BEGIN
		SELECT vo.NCIViewID, i.ImageId, i.ImageName, i.ImageSource, i.ImageAltText, i.TextSource, i.Url, i.Width, i.Height, i.Border, vo.Priority,
		dbo.udf_GetViewObjectProperty(i.ImageID, 'Clicklogging') AS ClickloggingEnabled 
		FROM ViewObjects vo INNER JOIN [Image] i ON vo.ObjectId = i.ImageId
		WHERE i.ImageName = @ImageName
		ORDER BY vo.Priority	
	END	

END
GO
GRANT EXECUTE ON [dbo].[usp_GetImageViewObject] TO [websiteuser_role]
GO
