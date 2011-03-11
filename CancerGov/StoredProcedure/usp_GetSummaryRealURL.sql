IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetSummaryRealURL]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetSummaryRealURL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_GetSummaryRealURL
	Object's type:	Stored procedure
	Purpose:	Get real URL
	
	Change History:
	2/22/2007 	Jay He

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetSummaryRealURL
       	@PrettyURL VARCHAR(2000)
AS
	
	SELECT	realurl, ObjectID
	FROM	PrettyURL 
	WHERE 	CurrentURL = @PrettyURL


GO
GRANT EXECUTE ON [dbo].[usp_GetSummaryRealURL] TO [websiteuser_role]
GO
