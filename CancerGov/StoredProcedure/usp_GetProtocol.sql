IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_GetProtocol]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_GetProtocol]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE dbo.usp_GetProtocol
	(
		@ProtocolID uniqueidentifier,
		@Version varchar(10)
	)
AS
BEGIN
	/******************************************
	Populate Protocol data 
	******************************************/
	DECLARE 	@PDQProtocolID int,
			@ProtocolStudyType uniqueidentifier,
			@AlternateID varchar(1000),
			@ListOfProtocolType varchar(1000),
			@tmpStr varchar(1000),
			@DataSize int,
			@PersonOrgRole	uniqueidentifier, 
			@PhoneType	uniqueidentifier, 
			@ProtocolSponsors varchar(1000)

	SELECT 	@PersonOrgRole  = dbo.GetCancerGovOrgRoleID(74),
			@PhoneType = dbo.GetCancerGovTypeID(179)

	SELECT 	@ProtocolStudyType = StudyTypeID
	FROM 		Protocol 
	WHERE 	ProtocolID = @ProtocolID	
	
	/******************************************
	Alternate protocol IDs
	******************************************/
	--PRINT 'Alternate protocol IDs'

	DECLARE  cursorProtocolAlternateID CURSOR
	FOR 	SELECT 	AlternateID		--PDQ field ID
		FROM 		ProtocolAlternateID
		WHERE 	ProtocolID = @ProtocolID

	OPEN CursorProtocolAlternateID
	FETCH NEXT FROM CursorProtocolAlternateID 	INTO @tmpStr 
	SELECT @AlternateID = NULL --LTRIM(RTRIM(@tmpStr))
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @AlternateID = ISNULL(@AlternateID + ',  ',  '') + LTRIM(RTRIM(@tmpStr))
		FETCH NEXT FROM CursorProtocolAlternateID 	INTO @tmpStr 
	END

	CLOSE CursorProtocolAlternateID
	DEALLOCATE CursorProtocolAlternateID

	/******************************************
	Protocol Type
	******************************************/
	--PRINT 'Protocol Type'

	DECLARE  cursorProtocolType CURSOR
	FOR
	SELECT  DISTINCT T.[Name]			--PDQ field TYPE
	FROM 	ProtocolType PT INNER JOIN Type T
		ON PT.Type = T.TypeID
		AND PT.ProtocolID = @ProtocolID

	OPEN cursorProtocolType 
	FETCH NEXT FROM cursorProtocolType INTO @tmpStr 
	SELECT @ListOfProtocolType =  NULL --LTRIM(RTRIM(@tmpStr )) 
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @ListOfProtocolType = ISNULL(@ListOfProtocolType  + ',  ','') + LTRIM(RTRIM(@tmpStr )) 
		FETCH NEXT FROM cursorProtocolType INTO @tmpStr 
	END
	CLOSE cursorProtocolType 
	DEALLOCATE cursorProtocolType 


	/******************************************
	Protocol Status information
	******************************************/
	--PRINT 'Protocol Status information'
	
	DECLARE @Status varchar(255),
		@StatusID uniqueidentifier,
		@StatusDate datetime, 
		@ActiveDate datetime,
		@ClosedDate datetime,
		@CompletedDate datetime,
		@TemporarilyClosedDate datetime
	
	SELECT 	@StatusDate = StatusDate, @StatusID = StatusID
	FROM 	Protocol
	WHERE 	ProtocolID = @ProtocolID
	
	IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolActiveStatusID())) 
	BEGIN
		-- 1 protocol is active
		SELECT 	@Status = 'Active',
			@ActiveDate = @StatusDate
	END 
	ELSE BEGIN
		IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolApprovedStatusID())) 
		BEGIN
			-- 2 protocol is approved
			SELECT 	@Status = 'Approved - Not yet active',
				@ActiveDate = @StatusDate
		END 
		ELSE BEGIN
			IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolClosedStatusID())) 
			BEGIN
				-- 3 protocol is closed
				SELECT 	@Status = 'Closed',
					@ClosedDate = @StatusDate
			END 
			ELSE BEGIN
				IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolCompletedStatusID())) 
				BEGIN
					-- 4 protocol is completed
					SELECT 	@Status = 'Completed',
						@CompletedDate = @StatusDate
				END 
				ELSE BEGIN
					IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolTempClosedStatusID())) 
					BEGIN
						-- 5 protocol is temporarily closed
						SELECT 	@Status = 'Temporarily Closed',
							@TemporarilyClosedDate = @StatusDate
					END 
					ELSE BEGIN
						IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolSpecialStatusID())) 
						BEGIN
							-- 86 protocol is special
							SELECT 	@Status = 'Special',
								@ActiveDate  = @StatusDate
						END 

						ELSE BEGIN
							IF  (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolUnavailableStatusID())) 
							BEGIN
								-- 200 protocol has no status
								SELECT 	@Status = 'Unavailable',
									@ActiveDate  = @StatusDate
							END 
						END -- 86 protocol is special
					END -- 5 protocol is temporarily closed
				END -- 4 protocol is completed
			END -- 3 protocol is closed
		END -- 2 protocol is approved
	END -- 1 protocol is active 

	
	-- IF protocol IsNew then also show New Status
	IF 'Y' = (SELECT IsNew FROM Protocol WHERE ProtocolID = @ProtocolID)
	BEGIN
		SELECT @Status = ISNULL( NULLIF(LTRIM(@Status), '') + ', ' , '') + 'New'  --PDQ field STAT
	END 
	
	--Correct Status Dates base on the Status History information

	IF (@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolCompletedStatusID()))--completed
	BEGIN
		SELECT 	TOP 1 
			@ClosedDate = StatusDate
		FROM 	ProtocolStatusHistory
		WHERE 	ProtocolID = @ProtocolID
			AND StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolClosedStatusID()) --closed status 	
	END 
	IF (	(@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolClosedStatusID())) --closed
		OR 
		(@StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolTempClosedStatusID())) --temporary closed
	   )	
	BEGIN
		SELECT 	TOP 1 
			@ActiveDate = ISNULL(StatusDate,(
				SELECT 	TOP 1
					StatusDate
				FROM 	ProtocolStatusHistory
				WHERE 	ProtocolID = @ProtocolID
					AND StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolApprovedStatusID()) --Approved
			))
		FROM 	ProtocolStatusHistory
		WHERE 	ProtocolID = @ProtocolID
			AND StatusID = dbo.GetCancerGovStatusID(dbo.PDQProtocolActiveStatusID()) --active
	END
	


	/******************************************
	@ProtocolSponsors 
	******************************************/
	DECLARE  cursorProtocolSponsor CURSOR
	FOR 	SELECT  DISTINCT T.[Name]
		FROM  	 ProtocolSponsor AS PS 
			INNER JOIN Type AS T
			ON PS.SponsorID = T.TypeID
			AND PS.ProtocolID = @ProtocolID

	OPEN cursorProtocolSponsor
	FETCH NEXT FROM cursorProtocolSponsor	INTO @tmpStr 
	SELECT @ProtocolSponsors  = NULL --LTRIM(RTRIM(@tmpStr))
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @ProtocolSponsors  = ISNULL(@ProtocolSponsors  + ',  ',  '') + LTRIM(RTRIM(@tmpStr))
		FETCH NEXT FROM cursorProtocolSponsor INTO @tmpStr 
	END

	CLOSE cursorProtocolSponsor
	DEALLOCATE cursorProtocolSponsor





	/******************************************
	General Protocol Data
	******************************************/
	--PRINT 'General Protocol Data'
	
	SELECT 	ProtocolID,
		SourceID, 		--PDQ field UI
		Title, 			--PDQ field NAME
		ShortTitle, 		--PDQ field SNAM
		AgeCriteria,		--PDQ field AGET
		LowerAge,		--PDQ field AGEL
		UpperAge,		--PDQ field AGEH
		@AlternateID AS AlternateIDs,	--PDQ field ID
		@ListOfProtocolType AS Type, 	--PDQ field TYPE 
		@Status as ProtocolCurrentStatus, --PDQ field STAT
		@ActiveDate AS ActiveDate,	--PDQ field SDAT
		@ClosedDate AS ClosedDate,	--PDQ field CDAT
		@CompletedDate AS CompletedDate,	--PDQ field TDAT
		@TemporarilyClosedDate AS TemporarilyClosedDate, --PDQ field PDAT,
		@ProtocolSponsors AS ProtocolSponsors 

	FROM 	Protocol 
	WHERE 	ProtocolID = @ProtocolID


	
	/******************************************
	Protocols details text data 
	******************************************/
	SELECT  
		UPPER(T.[Name]) as 'Name',
		PD.[Type],
		PD.Data 
	FROM 	ProtocolData PD Left JOIN Type T
		ON PD.Type = T.TypeID
	WHERE 	ProtocolID = @ProtocolID

	/******************************************
	Participating Organizations
	******************************************/
	SELECT  dbo.udf_GetProtocolContacts (  @ProtocolID )  AS ParticipatingOrganization
	/*SELECT 	P.GivenName + ' ' + P.Surname 
		+ ISNULL(', Chair Ph: ' + PH.Number, '') + '<br>'  
		+ O.[Name] AS ParticipatingOrganization
	FROM 	(select ProtocolOrgID, OrganizationID  from ProtocolOrganization where ProtocolID = @ProtocolID) As PO 
		INNER JOIN Organization AS O
			ON PO.OrganizationID = O.OrganizationID
		INNER JOIN ProtocolOrganizationPerson AS POP 
			ON PO.ProtocolOrgID = POP.ProtocolOrgID
		INNER JOIN Person AS P 
			ON POP.PersonID = P.PersonID 
			AND PersonOrgRole = @PersonOrgRole 
		INNER JOIN Affiliation A
			ON POP.PersonID = A.PersonID 
			AND PO.OrganizationID = A.OrganizationID
		LEFT JOIN Phone PH
			ON PH.OwnerID = A.AffiliationID
			AND  PH.Type = @PhoneType
			AND  PH.UsageOrder = 1	
	*/


	/******************************************
	Published Results Of Study
	******************************************/
	SELECT  C.SourceID AS CitationSourceID, 
		C.CitationID
	FROM	ProtocolCitation AS PC
		INNER JOIN Citation AS C
		ON C.CitationID = PC.CitationID
	WHERE 	ProtocolID = @ProtocolID


END
GO
