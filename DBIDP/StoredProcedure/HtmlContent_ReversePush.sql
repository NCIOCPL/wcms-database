IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HtmlContent_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[HtmlContent_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.HtmlContent_ReversePush
@htmlContentID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
begin try
--declare @htmlContentID uniqueidentifier,@updateUserID varchar(50)

		if exists (select 1 from dbo.Htmlcontent where HtmlcontentID = @htmlContentID)
			begin  		 	
					if @isDebug = 1 
							print 'Update Htmlcontent ' +	convert(varchar(50),@htmlContentID)
					update h
					set h.Title = ph.title,
						h.ImageHtml = ph.ImageHtml, 
						h.UpdateUserID = @updateUserID,
						h.UpdateDate = getdate() 
						from dbo.Htmlcontent h
							inner join PRODHtmlcontent ph on ph.HtmlcontentID = h.HtmlcontentID
						where  ph.HtmlcontentID = @htmlContentID 
			end
		else
			begin
					if @isDebug = 1 
							print 'Insert Htmlcontent ' +	convert(varchar(50),@htmlContentID)

					insert into dbo.Htmlcontent (
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
					from DBO.PRODHtmlcontent 
					where HtmlcontentID =  @htmlContentID 
			end
end try
		
		
begin catch
	print error_message()
	 
		
	return 50011
end catch



End

GO
GRANT EXECUTE ON [dbo].[HtmlContent_ReversePush] TO [websiteuser_role]
GO
