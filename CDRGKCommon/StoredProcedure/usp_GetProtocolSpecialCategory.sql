IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolSpecialCategory]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolSpecialCategory]
GO

/**********************************************************************************

	Object's name:	usp_GetProtocolSponsors
	Object's type:	Stored procedure
	Purpose:	Get all sponsors of protocols
	
	Change History:
	10/14/2004	Bryan Pizzillo

**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetProtocolSpecialCategory
AS

select distinct ProtocolSpecialCategory from dbo.ProtocolSpecialCategory order by ProtocolSpecialCategory

GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolSpecialCategory] TO [websiteuser_role]
GO
