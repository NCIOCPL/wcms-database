IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetObjectPropertyValues]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetObjectPropertyValues]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE usp_GetObjectPropertyValues
	(
	@ViewId	uniqueidentifier,
	@Property	varchar(30)
	)
AS
BEGIN
	SELECT vop.PropertyValue 
	FROM 	ViewObjects vo INNER JOIN ViewObjectProperty vop 
		ON vo.NCIViewObjectID = vop.NCIViewObjectID
	WHERE vo.NCIViewID = @ViewId
		 AND PropertyName = @Property
END

GO
