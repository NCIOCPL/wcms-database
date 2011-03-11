IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetHeaderViewObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetHeaderViewObject]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE usp_GetHeaderViewObject
	(
		@ViewId	uniqueidentifier,
		@ContentType	varchar(30),
		@HeaderType	varchar(30),
		@ObjectID uniqueidentifier = null			
	)

AS

	IF (@ObjectID is null)
	BEGIN
		SELECT h.HeaderId, h.ContentType, h.Data
		FROM ViewObjects vo INNER JOIN Header h ON vo.ObjectId = h.HeaderId
		WHERE h.ContentType = @ContentType 
			AND h.Type = @HeaderType 
			AND vo.NCIViewId = @ViewId
	END ELSE
	BEGIN
		SELECT h.HeaderId, h.ContentType, h.Data
		FROM ViewObjects vo INNER JOIN Header h ON vo.ObjectId = h.HeaderId
		WHERE h.ContentType = @ContentType 
			AND h.Type = @HeaderType 
			AND vo.NCIViewId = @ViewId
			AND h.HeaderId = @ObjectID
	END
GO
GRANT EXECUTE ON [dbo].[usp_GetHeaderViewObject] TO [websiteuser_role]
GO
