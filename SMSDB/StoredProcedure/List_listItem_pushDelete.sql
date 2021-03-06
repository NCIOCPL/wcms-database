IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_listItem_pushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_listItem_pushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.List_listItem_pushDelete
@listItemInstanceID uniqueidentifier,
@ListID uniqueidentifier,
@isDebug bit =0
AS
Begin
	declare @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_listItem_pushDelete ' +	convert(varchar(50),@listItemInstanceID)
	begin try

		if @isDebug = 1 
			print 'Delete from dbo.PRODListItem ' +	convert(varchar(50),@listItemInstanceID)

		delete from dbo.PRODListITem where listItemInstanceID = @listItemInstanceID and 
			not exists (select 1 from dbo.ListITem where listItemInstanceID = @listItemInstanceID)

	end try

begin catch
	print error_message()
	 	
	return 11110
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_listItem_pushDelete] TO [websiteuser_role]
GO
