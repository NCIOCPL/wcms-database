IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DeleteDrugInfoSummaryPreview]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[DeleteDrugInfoSummaryPreview]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure dbo.DeleteDrugInfoSummaryPreview
@DocumentID  UniqueIdentifier
as
BEGIN
	declare @NCIViewID UniqueIdentifier 
	SELECT @NCIViewID= NCIViewID from cancerGovStaging.dbo.viewObjects where objectid = @DocumentId and type = 'DOCUMENT'

	Begin tran

	delete from cancerGovStaging.dbo.[Document]
		where documentid = @documentid

	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGovStaging.dbo.ViewObjects where NCIViewid =  @NCIViewID 
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

	delete from cancerGovStaging.dbo.PrettyURL where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGovStaging.dbo.Viewproperty where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	delete from cancerGovStaging.dbo.NCIView where NCIViewid =  @NCIViewID 
	IF (@@ERROR <> 0)
		BEGIN
			Rollback tran
			RAISERROR ( 70004, 16, 1)
			RETURN 70004
		END 

	commit tran
END

GO
GRANT EXECUTE ON [dbo].[DeleteDrugInfoSummaryPreview] TO [gatekeeper_role]
GO
