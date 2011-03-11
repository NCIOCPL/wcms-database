IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SaveProtocolSponsors]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SaveProtocolSponsors]
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
CREATE PROCEDURE dbo.usp_SaveProtocolSponsors
(
	@protocolid int, 
	@updateUserid varchar(50), 
	@SponsorName varchar(100), 
	@isDebug bit = 0
	)
 AS
BEGIN
	SET NOCOUNT ON 
	

	declare @updateDate datetime
	set @updatedate = getdate()	

	declare @SponsorID int 
	
	select @SponsorID = SponsorID from dbo.Sponsor where SponsorName = @SponsorName

	if @SponsorID is NULL
		BEGIN
				insert into dbo.Sponsor
					(	
						SponsorName,
						UpdateUserID,
						UpdateDate)
				values(
						@SponsorName,
						@UpdateUserID,
						@UpdateDate)

				IF (@@ERROR <> 0)
				BEGIN
					
					RAISERROR ( 69990, 16, 1, @ProtocolID,'Sponsor')
					RETURN 69990
				END 
				
				set @SponsorID = scope_identity()
		END

	insert into dbo.ProtocolSponsors
		(
			protocolid,
			updateUserid,
			Sponsorid,
			UpdateDate)
		values(
			@protocolid,
			@updateUserid,
			@SponsorID,
			@UpdateDate)

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 69990, 16, 1, @ProtocolID,'ProtocolSponsors')
		RETURN 69990
	END 


	if @isDebug =1  PRINT  '  ***       - dbo.ProtocolSponsors table Saved for ID: '+ convert(varchar(50), @ProtocolID)
		
END



GO
GRANT EXECUTE ON [dbo].[usp_SaveProtocolSponsors] TO [Gatekeeper_role]
GO
