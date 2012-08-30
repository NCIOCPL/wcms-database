IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_pushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_pushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.HtmlContent_pushDelete
@htmlContentID uniqueidentifier,
@isDebug bit = 0
AS
Begin
begin try
--declare @htmlContentID uniqueidentifier,@updateUserID varchar(50)

		if @isDebug = 1 
			print 'Delete PRODHtmlcontent ' +	convert(varchar(50),@htmlContentID)
		delete from dbo.PRODHtmlcontent where htmlcontentid = @htmlcontentid 
			and not exists (select 1 from htmlcontent where htmlcontentid = @htmlcontentid)
		
		
end try
		
		
begin catch
	print error_message()
	 
		
	return 50010
end catch



End

GO
GRANT EXECUTE ON [dbo].[HtmlContent_pushDelete] TO [websiteuser_role]
GO
