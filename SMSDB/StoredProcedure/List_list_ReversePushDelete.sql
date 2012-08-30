IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_list_ReversePushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_list_ReversePushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.List_list_ReversePushDelete
@listID uniqueidentifier,
@isDebug bit =0
AS
Begin
	declare @listItemInstanceID uniqueidentifier, @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_list_ReversePushDelete ' +	convert(varchar(50),@listID)
	begin try

	if exists (select 1 from dbo.List where listID = @listID) and (not exists  (select 1 from dbo.PRODList where listID = @listID) )
		begin
				
			if @isDebug = 1 
				print 'Delete from dbo.ListItem ' +	convert(varchar(50),@listID)

			declare DEL_ListItemInstance cursor fast_forward for
				select 	listItemInstanceID from dbo.listItem where listid = @listID
				open DEL_ListItemInstance	

				FETCH NEXT FROM  DEL_ListItemInstance INTO @listItemInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.List_list_ReversePushDelete''s dbo.List_list_ReversePushDeleteDelete ' +	convert(varchar(50),@listItemInstanceID)
							exec @rtnValue =dbo.List_ListItem_ReversePushDelete @listItemInstanceID, @listID,@isDebug
							if @rtnValue <> 0 
								begin
									CLOSE DEL_ListItemInstance
									DEALLOCATE DEL_ListItemInstance
									return @rtnValue
								end
						FETCH NEXT FROM DEL_ListItemInstance INTO @listItemInstanceID
					END
				CLOSE DEL_ListItemInstance
				DEALLOCATE DEL_ListItemInstance
	
			if @isDebug = 1 
				print 'Delete from dbo.List ' +	convert(varchar(50),@listID)
			delete	from dbo.List where listid = @listID

		end
		
	
	end try

begin catch
	print error_message()
	 	
	return 11211
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_list_ReversePushDelete] TO [websiteuser_role]
GO
