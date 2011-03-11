IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetExternalObject]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetExternalObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:
*
*	To Do List:
*
*/



CREATE PROCEDURE dbo.usp_GetExternalObject
	(
	@ViewId uniqueidentifier,
	@ExtObjId uniqueidentifier
	)
AS
BEGIN
	SELECT ExternalObjectID,
		Format, 
		Description,
		Path,
		Text,
		dbo.udf_GetViewObjectPrettyUrl(@ViewId, @ExtObjId) AS PrettyUrl
	FROM ExternalObject 
	WHERE ExternalObjectID = @ExtObjId
END

GO
GRANT EXECUTE ON [dbo].[usp_GetExternalObject] TO [websiteuser_role]
GO
