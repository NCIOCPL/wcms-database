IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[udf_GetProtocolContacts]') AND xtype in (N'FN', N'IF', N'TF'))
DROP FUNCTION [dbo].[udf_GetProtocolContacts]
GO
/*
* 	Procedure Return Protocol Contacts (mainly Chair or Group Chair in the case of closed protocols) 
*
*		For every LEAD AND SECONDARY LEAD ORGS 
*		If ProtocolOrg Status ACTIVE (active, approved)		
*			If protocol Approved not yet active then skip next row and get the chairman first
*			Get Protocol Chair (check all chiidren for current lead org)
*			If no chair was found try to get ChairMan for current lead org itself
*			If no chair was found try to get ChairMan OR Protocol Chair for current lead org itself	
*			If no chair was found try to get Group Chair for current lead org itself	
*		If ProtocolOrg Status NOT ACTIVE (closed, temporarily closed, completed)		
*			Get Group Chair
*			If no chair was found try to get Protocol Chair
*
* 
* 	Change History:
*		01/07/2002 	Alex Pidlisnyy	Add logic to pick also Protocol Chair for closed protocols if Group Chair not found
*						This fix implemented before Contacts wasn't found for protocol 3155
*		02/08/2002 	Alex Pidlisnyy	Add another <p> tag between contacts
*		02/12/2002 	Alex Pidlisnyy	If protocol Approved not yet active then get the chairman first
*
*/

CREATE FUNCTION dbo.udf_GetProtocolContacts
	(
	@ProtocolID uniqueidentifier
	)
RETURNS  varchar(8000) 
AS

BEGIN

	DECLARE @Result varchar(8000),
		@LeadOrgName varchar(256),
		@Phone varchar(50),
		@ChairID uniqueidentifier,
		@LeadOrgID uniqueidentifier,
		@LeadProtOrgID uniqueidentifier,
		@LeadOrgRole uniqueidentifier,
		@SecondaryLeadOrgRole uniqueidentifier,
		@ProtocolChairRole uniqueidentifier,
		@GroupChairRole  uniqueidentifier,
		@VocePhoneType  uniqueidentifier,
		@PrimaryAffilType uniqueidentifier,
		@Chairman uniqueidentifier, 
		@tmpStr varchar(255),		
		@IsActiveProtocol varchar(1),		
		@IsApprovedProtocol varchar(1)

	SELECT 	@LeadOrgRole = dbo.GetCancerGovOrgRoleID(69),
		@SecondaryLeadOrgRole = dbo.GetCancerGovOrgRoleID(70),
		@VocePhoneType = dbo.GetCancerGovTypeID(179), 
		@PrimaryAffilType = dbo.GetCancerGovTypeID(176), --primary
		@Result = NULL,
		@ProtocolChairRole = dbo.GetCancerGovOrgRoleID(74),
		@GroupChairRole = dbo.GetCancerGovOrgRoleID(14),
		@Chairman = dbo.GetCancerGovOrgRoleID(14),
		@tmpStr = '',
		@ChairID = NULL,
		@IsActiveProtocol = 'N',
		@IsApprovedProtocol = 'N' 

	IF EXISTS(SELECT * FROM vwActiveProtocol WHERE ProtocolID = @ProtocolID)
	BEGIN
		SET @IsActiveProtocol = 'Y' 
	END 	

	IF EXISTS(SELECT ProtocolID FROM CancerGov..Protocol WHERE StatusID = dbo.GetCancerGovStatusID( 2 ) /*Approved*/ AND ProtocolID = @ProtocolID)
	BEGIN
		SET @IsApprovedProtocol = 'Y'
	END

	--PRINT 	'FIND OUT ACTIVE LEAD AND SECONDARY LEAD ORGS' 
	DECLARE LeadOrg_cursor CURSOR FOR 
	SELECT 	O.[Name], 
		O.OrganizationID, 
		ProtocolOrgID 
	FROM 	ProtocolOrganization AS P_O
		INNER JOIN Organization AS O
			ON O.OrganizationID =  P_O.OrganizationID 
	WHERE 	P_O.OrganizationRoleID IN ( @LeadOrgRole, @SecondaryLeadOrgRole )
		AND P_O.ProtocolID = @ProtocolID 	
	ORDER BY O.[Name]

	OPEN LeadOrg_cursor
	FETCH NEXT FROM LeadOrg_cursor INTO @LeadOrgName, @LeadOrgID, @LeadProtOrgID
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT ''
		--PRINT '------------------------- START -------------------------'
		--PRINT '     ORGANIZATION NAME: "' + LTRIM(RTRIM(@LeadOrgName)) + '"'
		--PRINT '	    ORGANIZATION ID: {' + convert(varchar(36), @LeadOrgID) + '} '
		--PRINT ''

		IF @IsActiveProtocol = 'Y'
		BEGIN
			--PRINT 	'     ACTIVE STATUS' 
			If @IsApprovedProtocol = 'Y'
			BEGIN
				--PRINT 	'      GET CHAIRMAN FOR CHILDREN OF LEAD ORD' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganization AS PO
					INNER JOIN ProtocolOrganizationPerson AS POP 
						ON PO.ProtocolOrgID = POP.ProtocolOrgID
						AND POP.PersonOrgRole = @Chairman
				WHERE 	PO.ProtocolOrgID = @LeadProtOrgID
			END
			ELSE 
			BEGIN
				--PRINT 	'      GET PROTOCOL CHAIR FOR CHILDREN OF LEAD ORD' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganization AS PO
					INNER JOIN ProtocolOrganizationPerson AS POP 
						ON PO.ProtocolOrgID = POP.ProtocolOrgID
						AND PersonOrgRole = @ProtocolChairRole
				WHERE 	PO.ParentProtocolOrgID = @LeadProtOrgID
			END 
			
			IF @ChairID IS NULL
			BEGIN
				--PRINT 	'      GET PROTOCOL CHAIR FOR CHILDREN OF LEAD ORD' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganization AS PO
					INNER JOIN ProtocolOrganizationPerson AS POP 
						ON PO.ProtocolOrgID = POP.ProtocolOrgID
						AND PersonOrgRole = @ProtocolChairRole
				WHERE 	PO.ParentProtocolOrgID = @LeadProtOrgID
			END 

			IF @ChairID IS NULL
			BEGIN
				--PRINT 	'      GET CHAIRMAN FOR CHILDREN OF LEAD ORD' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganization AS PO
					INNER JOIN ProtocolOrganizationPerson AS POP 
						ON PO.ProtocolOrgID = POP.ProtocolOrgID
						AND POP.PersonOrgRole = @Chairman
				WHERE 	PO.ProtocolOrgID = @LeadProtOrgID
			END 

			IF @ChairID IS NULL
			BEGIN
				--PRINT 	'     GET PROTOCOL CHAIR OR CHAIRMAN  FOR LEAD ORG ITSELF' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganization AS PO
					INNER JOIN ProtocolOrganizationPerson AS POP 
						ON PO.ProtocolOrgID = POP.ProtocolOrgID
						AND POP.PersonOrgRole IN (@Chairman, @ProtocolChairRole)
				WHERE 	PO.ProtocolOrgID = @LeadProtOrgID
			END 

			IF @ChairID IS NULL
			BEGIN
				--PRINT 	'       GET PROTOCOL GROUP CHAIR' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganization AS PO
					INNER JOIN ProtocolOrganizationPerson AS POP 
						ON PO.ProtocolOrgID = POP.ProtocolOrgID
						--AND PersonOrgRole IN ( @GroupChairRole, @ProtocolChairRole )
						AND PersonOrgRole = @GroupChairRole
				WHERE 	PO.ProtocolID = @ProtocolID 	
			END			
		END
		ELSE
		BEGIN
			--PRINT 	'     CLOSED STATUS' 
			--PRINT 	'     GET GROUP CHAIR' 		
			SELECT 	@ChairID = POP.PersonID
			FROM 	ProtocolOrganizationPerson AS POP 
			WHERE 	POP.ProtocolOrgID = @LeadProtOrgID
				AND PersonOrgRole = @GroupChairRole

			IF @ChairID IS NULL
			BEGIN
				--PRINT 	'      GET GROUP CHAIR DO NOT SUCCED, GET PROTOCOL CHAIR' 		
				SELECT 	@ChairID = POP.PersonID
				FROM 	ProtocolOrganizationPerson AS POP 
				WHERE 	POP.ProtocolOrgID = @LeadProtOrgID
					AND PersonOrgRole = @ProtocolChairRole 
			END
		END
		--PRINT 	'     CHAIR ID = {' + ISNULL( convert( varchar(36), @ChairID), 'NULL' )+'}' 		

		--PRINT 	'     GET PHONE FOR CHAIR BASE ON AFFILIATION INFO' 		
		SELECT  @Phone = P.Number
		FROM 	Phone AS P 
			INNER JOIN Affiliation AS A 
				ON P.OwnerID = A.AffiliationID
				AND P.OwnerType = 'PERSON_DIRECT_AFFILIATION_PHONE' 
				AND A.PersonID = @ChairID
				AND A.OrganizationID = @LeadOrgID 
		WHERE 	P.Type = @VocePhoneType 
		ORDER BY UsageOrder
		
		IF @Phone IS NULL 
		BEGIN
			--PRINT 	'       @Phone IS NULL -- GET PHONE BASE ON AFFILIATION INFO' 		
			SELECT  @Phone = P.Number
			FROM 	Phone AS P 
				INNER JOIN Affiliation AS A 
				ON P.OwnerID = A.AffiliationID
				AND P.OwnerType = 'PERSON_DIRECT_AFFILIATION_PHONE' 
				AND A.Type = @PrimaryAffilType 
			WHERE 	P.Type = @VocePhoneType 
				AND A.PersonID = @ChairID
			ORDER BY UsageOrder
		END
	
		IF @Phone IS NULL
		BEGIN
			--PRINT 	'       @Phone IS NULL -- GET ORGANIZATION PHONE' 		
			SELECT  @Phone = Number
			FROM 	Phone 
			WHERE 	OwnerType = 'ORGANIZATION_PHONE'
				AND OwnerID = @LeadOrgID
				AND Type = @VocePhoneType 
			ORDER BY UsageOrder
		END
	
		SELECT 	@tmpStr  = '<p>'
			+ ISNULL(P.GivenName,'') + ' ' + ISNULL(P.Surname,'') 
			+ ISNULL(', Chair Ph: ' + @Phone, '') + '<br>'  
			+ ISNULL(@LeadOrgName,'')
			+ '</p>'
			+ '<p> </p>'
		FROM	Person AS P
		WHERE   PersonID = @ChairID 

		SELECT 	@Result = ISNULL(@Result, '') + ISNULL(@tmpStr,'') 

		--PRINT '     CLEAR TMP PARAMETERS'
		SELECT 	@Phone = NULL, 
			@ChairID = NULL
		--PRINT '     RESULT: ' + @tmpStr 
		--PRINT '---------------- GO TO NEXT ORG (if any) ----------------'
		--PRINT ''
		FETCH NEXT FROM LeadOrg_cursor INTO @LeadOrgName, @LeadOrgID, @LeadProtOrgID
	END
	
	CLOSE LeadOrg_cursor
	DEALLOCATE LeadOrg_cursor

	RETURN @Result 
END



































GO
