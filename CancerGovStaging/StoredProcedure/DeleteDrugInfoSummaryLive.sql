IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DeleteDrugInfoSummaryLive]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DeleteDrugInfoSummaryLive]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure dbo.DeleteDrugInfoSummaryLive
@DocumentID  UniqueIdentifier 
as
BEGIN
	declare @NCIViewID UniqueIdentifier 
	SELECT @NCIViewID= NCIViewID from cancerGov.dbo.viewObjects where objectid = @DocumentId and type = 'DOCUMENT'

	Begin tran

	delete from cancerGov.dbo.[Document]
		where documentid =  @DocumentID

	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGov.dbo.ViewObjects where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGov.dbo.PrettyURL where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGov.dbo.Viewproperty where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGov.dbo.NCIView where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 
	
	update cancerGovstaging.dbo.nciview set isonProduction = 0, status = 'EDIT'
		where nciviewid  = @NCIViewID 

	commit tran
END

GO
GRANT EXECUTE ON [dbo].[DeleteDrugInfoSummaryLive] TO [gatekeeper_role]
GO
