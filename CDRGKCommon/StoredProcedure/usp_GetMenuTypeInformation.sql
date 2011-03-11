IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetMenuTypeInformation]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetMenuTypeInformation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**********************************************************************************

	Object's name:	usp_GetMenuTypeInformation
	Object's type:	Stored procedure
	Purpose:	Get all cancer types or Sub type
	
	Change History:
	10/05/2004	Lijia Chu	

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetMenuTypeInformation
	@MenuTypeId	smallint,
	@ParentID int
AS

IF @ParentID IS NOT NULL

	SELECT	DisplayName, 
		CDRID,
		DisplayName +';'+ convert(VARCHAR(20),CDRID)	DisplayNameID
	FROM	CDRMenus
	WHERE 	ParentID=@ParentID
	ORDER BY ISNULL(SortName,DisplayName)

ELSE
	SELECT	m1.DisplayName, 
		m1.CDRID,
		m1.DisplayName+';'+ convert(VARCHAR(20),m1.CDRID)	DisplayNameID
	FROM	CDRMenus m1, CDRMenus m2
	WHERE 	m1.ParentID=m2.CDRID
	AND	m2.ParentID IS NULL
	AND	m2.MenuTypeId=@MenuTypeId
	ORDER BY ISNULL(m1.SortName,m1.DisplayName)
	


GO
GRANT EXECUTE ON [dbo].[usp_GetMenuTypeInformation] TO [websiteuser_role]
GO
