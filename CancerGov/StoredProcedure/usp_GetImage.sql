IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetImage]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetImage]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE usp_GetImage
	(
	@ImageId	uniqueidentifier
	)
AS
BEGIN
	SELECT  ImageID,
		ImageName,
		ImageSource,
		ImageAltText,
		TextSource,
		Url,
		Width,
		Height,
		Border,
		UpdateDate,
		UpdateUserID,
		dbo.udf_GetViewObjectProperty(ImageID, 'Clicklogging') AS ClickloggingEnabled
	FROM 	[Image]
	WHERE 	ImageID = @ImageID

END
GO
GRANT EXECUTE ON [dbo].[usp_GetImage] TO [websiteuser_role]
GO
