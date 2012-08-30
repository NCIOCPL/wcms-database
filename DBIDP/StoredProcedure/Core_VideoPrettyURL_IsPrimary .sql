IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_VideoPrettyURL_IsPrimary ]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_VideoPrettyURL_IsPrimary ]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*******************************************************
* Purpose:	Checks to see if a prettyurl is primary
* Author:	AshishB
* Date:		07/05/2007
* Params: 
*	@nihID -- The NIHID of the user to check
* exec [Core_VideoPrettyURL_IsUnique] '3453453456'

********************************************************/
CREATE PROCEDURE [dbo].[Core_VideoPrettyURL_IsPrimary ]
	@VideoPrettyURLID varchar(512)
AS
BEGIN
	
	SELECT IsPrimary FROM dbo.VideoPrettyURL WHERE VideoPrettyURLID = @VideoPrettyURLID
		 

		 
END


GO
GRANT EXECUTE ON [dbo].[Core_VideoPrettyURL_IsPrimary ] TO [websiteuser_role]
GO
