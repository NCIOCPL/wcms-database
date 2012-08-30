IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.HtmlContent_push
@htmlContentID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
begin try
--declare @htmlContentID uniqueidentifier,@updateUserID varchar(50)

		if exists (select 1 from dbo.PRODHtmlcontent where HtmlcontentID = @htmlContentID)
			begin  		 	
					if @isDebug = 1 
							print 'Update PRODHtmlcontent ' +	convert(varchar(50),@htmlContentID)
					update ph
					set ph.Title = h.title,
						ph.ImageHtml = h.ImageHtml, 
						ph.UpdateUserID = @updateUserID,
						ph.UpdateDate = getdate() 
						from dbo.PRODHtmlcontent ph
							inner join Htmlcontent h on ph.HtmlcontentID = h.HtmlcontentID
						where  ph.HtmlcontentID = @htmlContentID 
			end
		else
			begin
					if @isDebug = 1 
							print 'Insert PRODHtmlcontent ' +	convert(varchar(50),@htmlContentID)

					insert into dbo.PRODHtmlcontent (
						HtmlContentID,
						title,
						imagehtml,
						CreateUserID,
						CreateDate,
						UpdateUserID,
						UpdateDate)
					select 
						HtmlcontentID,
						title,
						imagehtml,
						@UpdateUserID,
						getdate(),
						@UpdateUserID,
						getdate()
					from DBO.Htmlcontent 
					where HtmlcontentID =  @htmlContentID 
			end
end try
		
		
begin catch
	print error_message()
	 
		
	return 50010
end catch



End

GO
GRANT EXECUTE ON [dbo].[HtmlContent_push] TO [websiteuser_role]
GO
