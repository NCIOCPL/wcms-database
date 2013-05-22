IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolLeadOrg]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolLeadOrg]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	NCI - National Cancer Institute
*	
*	Purpose:	
*
*	Objects Used:
*
*	Change History:

*	To Do List:
*
*/
CREATE PROCEDURE dbo.usp_SaveProtocolLeadOrg
	(
		@ProtocolContactInfoID int  output, 
		@ProtocolID int, 
		@OrganizationID int, 
		@PersonID int, 
		@OrganizationName varchar(500), 
		@PersonGivenName varchar(255), 
		@PersonSurName varchar(255), 
		@UpdateUserID varchar(50), 
		@PersonProfessionalSuffix varchar(255), 
		@City varchar(100), 
		@StateID int, 
		@Country varchar(255), 
		@OrganizationRole varchar(100), 
		@PersonRole varchar(100), 
		@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	
	declare @updateDate datetime
	set @updatedate = getdate()	
	
	declare @shortName varchar(50)
	
	select @shortName = shortname from dbo.politicalSubunit where politicalsubunitid =  @StateID

	insert into dbo.ProtocolLeadOrg
	(	
		ProtocolID,
		OrganizationID,
		PersonID,
		OrganizationName,
		PersonGivenName,
		PersonSurName,
		UpdateUserID,
		PersonProfessionalSuffix,
		City,
		State,
		Country,
		OrganizationRole,
		PersonRole,
		updateDate
	)
	VALUES (
			@ProtocolID,
			@OrganizationID,
			@PersonID,
			@OrganizationName,
			@PersonGivenName,
			@PersonSurName,
			@UpdateUserID,
			@PersonProfessionalSuffix,
			@City,
			@shortName,
			@Country,
			@OrganizationRole,
			@PersonRole,
			@updateDate
		)
	
	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolLeadOrg')
		RETURN 69990
	END 

	set @ProtocolContactInfoID = scope_identity()

	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolLeadOrg table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		

	
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolLeadOrg] TO [Gatekeeper_role]
GO
