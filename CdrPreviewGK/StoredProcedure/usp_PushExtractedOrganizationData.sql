IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_PushExtractedOrganizationData]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_PushExtractedOrganizationData]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.usp_PushExtractedOrganizationData
	(
	@DocumentID 	int,
	@UpdateUserID 	varchar(50),
	@CleanOldData	varchar(3) = 'YES' ,
	@isDebug bit = 0
	)
AS
BEGIN
	set nocount on
	--**************************************************************************************************************
	DECLARE @UpdateDate datetime, @r int

	--**************************************************************************************************************
	SELECT 	@UpdateDate = GETDATE()	

	--**************************************************************************************************************
	if @isdebug =  1  PRINT  '           START - Push Organization data from PREVIEW  to LIVE'

	IF @CleanOldData = 'Yes' 
	BEGIN
		EXEC @r = CDRLiveGK..usp_ClearExtractedOrganizationData @DocumentID
		IF (@@ERROR <> 0) or (@r <> 0)
		BEGIN
			
			RAISERROR ( 70001, 16, 1, @documentID, 'OrganizationName')
			RETURN 70001
		END 
	END

		--**************************************************************************************************************
	if @isdebug =  1  PRINT  '           Push dbo.OrganizationName table '

	-- select * from CDRPreviewGK.dbo.OrganizationName 
	INSERT INTO CDRLiveGK.dbo.OrganizationName
		(
		OrganizationID,
		[Name],
		Type,
		UpdateDate,
		UpdateUserID
		)
	SELECT 	OrganizationID,
		[Name],
		Type,
		@UpdateDate,
		@UpdateUserID
	FROM 	CDRPreviewGK..OrganizationName
	WHERE 	OrganizationID = @DocumentID 	

	IF (@@ERROR <> 0)
	BEGIN
		
		RAISERROR ( 70000, 16, 1, @documentID, 'OrganizationName')
		RETURN 70000
	END 

	if @isdebug =  1  PRINT  '           DONE - Push Organization data from PREVIEW  to LIVE'
	
	RETURN 0

END

GO
GRANT EXECUTE ON [dbo].[usp_PushExtractedOrganizationData] TO [Gatekeeper_role]
GO
