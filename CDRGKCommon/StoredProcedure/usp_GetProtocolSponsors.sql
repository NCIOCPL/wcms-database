IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolSponsors]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolSponsors]
GO
/**********************************************************************************

	Object's name:	usp_GetProtocolSponsors
	Object's type:	Stored procedure
	Purpose:	Get all sponsors of protocols
	
	Change History:


**********************************************************************************/


CREATE PROCEDURE dbo.usp_GetProtocolSponsors
AS

select sponsorName from dbo.sponsor
where sponsorID in
(select distinct SponsorID 
from dbo.ProtocolSponsors )
order by SponsorName

GO
GRANT EXECUTE ON [dbo].[usp_GetProtocolSponsors] TO [websiteuser_role]
GO
