IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PushDrugInfoToProduction]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[PushDrugInfoToProduction]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure dbo.PushDrugInfoToProduction
@NCIViewID  UniqueIdentifier  output ,
@documentid uniqueidentifier,
@updateUserID varchar(50)
as
begin
	set nocount on
	SELECT @NCIViewID= NCIViewID from dbo.viewObjects where objectid = @DocumentId and type = 'DOCUMENT'
	if @NCIViewID is not null
	begin
		declare @r int
		Update dbo.NCIView
			set 	Status ='SUBMIT',
				UpdateDate	= getdate(),  
				UpdateUserID  	=@updateUserID  
		where NCIViewID = @NCIViewID
		if @@error <>0 
			return 70004
		exec @r = dbo.usp_PushNCIViewToProduction @nciviewid, @updateUserID	
		return @r
	end
	 else
		return 70004
end

GO
GRANT EXECUTE ON [dbo].[PushDrugInfoToProduction] TO [gatekeeper_role]
GO
