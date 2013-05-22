IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetNCISection]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetNCISection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--***********************************************************************
-- Create New Object 
--************************************************************************

CREATE PROCEDURE dbo.usp_GetNCISection

	@SectionId 	uniqueidentifier = null

AS

BEGIN

IF NULLIF(@SectionId, '') IS NULL
	SELECT * FROM NCISection
ELSE
	SELECT * FROM NCISection WHERE NCISectionID = @SectionId

END


GO
GRANT EXECUTE ON [dbo].[usp_GetNCISection] TO [websiteuser_role]
GO
