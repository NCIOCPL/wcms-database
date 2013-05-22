IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCISiteSections]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCISiteSections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_GetNCISiteSections

	@SiteID 	varchar(36)

AS

BEGIN

IF NULLIF(@SiteID, '') IS NOT NULL

	SELECT * 
	FROM NCISection 
	WHERE SiteID = @SiteID
	ORDER BY OrderLevel ASC

END

GO
