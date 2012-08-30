IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_listItem_ReversePushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_listItem_ReversePushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.List_listItem_ReversePushDelete
@listItemInstanceID uniqueidentifier,
@ListID uniqueidentifier,
@isDebug bit =0
AS
Begin
	declare @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_listItem_ReversePushDelete ' +	convert(varchar(50),@listItemInstanceID)
	begin try

		if @isDebug = 1 
			print 'Delete from dbo.ListItem ' +	convert(varchar(50),@listItemInstanceID)

		delete from dbo.ListITem where listItemInstanceID = @listItemInstanceID and 
			not exists (select 1 from dbo.PRODListITem where listItemInstanceID = @listItemInstanceID)

	end try

begin catch
	print error_message()
	 	
	return 11111
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_listItem_ReversePushDelete] TO [websiteuser_role]
GO
