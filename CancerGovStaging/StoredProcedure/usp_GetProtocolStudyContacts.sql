IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocolStudyContacts]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocolStudyContacts]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE dbo.usp_GetProtocolStudyContacts
	(
		@ProtocolID uniqueidentifier
	)
AS	
BEGIN

	DECLARE  	@StatusID uniqueidentifier
	
	SELECT 	@StatusID = StatusID
	FROM 	Protocol
	WHERE 	ProtocolID = @ProtocolID

	IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolActiveStatusID())) 
	BEGIN
		PRINT 'Protocol In ACTIVE Status, we can return Study contacts'
		SELECT 	DISTINCT 
			Country, 
			State,
			PersonName 
			+ ISNULL(', Ph: ' + PhoneNumber, '') + '<br>'  
			+ OrgInfo AS StudyContact,
			OrgInfo  
		FROM 	ProtocolStudyContact
		WHERE	ProtocolID = @ProtocolID
		ORDER BY Country, State, OrgInfo, StudyContact
	END
	ELSE BEGIN
		PRINT 'Protocol NOT In ACTIVE Status, no recordset will be returned'
	END

END
GO
