IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_ReversePushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_ReversePushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.HtmlContent_ReversePushDelete
@htmlContentID uniqueidentifier,
@isDebug bit = 0
AS
Begin
begin try
--declare @htmlContentID uniqueidentifier,@updateUserID varchar(50)

		if @isDebug = 1 
			print 'Delete Htmlcontent ' +	convert(varchar(50),@htmlContentID)
		delete from dbo.Htmlcontent where htmlcontentid = @htmlcontentid 
			and not exists (select 1 from PRODhtmlcontent where htmlcontentid = @htmlcontentid)
		
		
end try
		
		
begin catch
	print error_message()
	 
		
	return 50011
end catch



End

GO
GRANT EXECUTE ON [dbo].[HtmlContent_ReversePushDelete] TO [websiteuser_role]
GO
