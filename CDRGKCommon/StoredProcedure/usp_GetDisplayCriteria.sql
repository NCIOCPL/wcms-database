IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetDisplayCriteria]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetDisplayCriteria]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Stored Procedure dbo.usp_GetDisplayCriteria    Script Date: 1/20/2009 5:46:51 PM ******/


/**********************************************************************************

	Object's name:	usp_GetDisplayCriteria
	Object's type:	store proc
	Purpose:	Load the XML structure from ParameterTwo of the   

			Search returns a single string value

**********************************************************************************/	

CREATE procedure dbo.usp_GetDisplayCriteria
(
	@ProtocolSearchID	int
)  
AS
BEGIN 

set nocount on

	SELECT ParameterTwo AS DisplayCriteria
	FROM   dbo.ProtocolSearch  p  WITH (NOLOCK)
	WHERE  ProtocolSearchID = @ProtocolSearchID 

END

GO
GRANT EXECUTE ON [dbo].[usp_GetDisplayCriteria] TO [websiteuser_role]
GO
