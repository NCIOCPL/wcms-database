IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************
* Purpose:	Gets all of the video pretty urls.
* Author:	BryanP
* Date:		11/06/07
* Params: 
*	
********************************************************/
CREATE PROCEDURE [dbo].[Core_VideoPrettyURL_GetAll] 
AS
BEGIN

	SELECT
		VideoPrettyUrlID,
		VideoID,
		PrettyUrl,
		RealUrl,
		IsPrimary
	FROM VideoPrettyUrl

END

GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_GetAll] TO [websiteuser_role]
GO
