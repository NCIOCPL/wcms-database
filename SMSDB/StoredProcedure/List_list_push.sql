IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_list_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_list_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.List_list_push
@listID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit =0
AS
Begin
	declare @listItemInstanceID uniqueidentifier, @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_list_push ' +	convert(varchar(50),@listID)
	begin try

	if exists (select 1 from dbo.PRODList where listID = @listID)
		begin
			if @isDebug = 1 
				print 'Update PRODList ' +	convert(varchar(50),@listID)
			update Pl
				set 
				pl.Description = l.description,
				pl.ShowLinkDescriptions = l.ShowLinkDescriptions,
				pl.ShowShortTitle = l.showShorttitle,
				pl.CreateUserID =  @updateUserID,
				pl.CreateDate = getdate(),
				pl.UpdateUserID = @updateuserid,
				pl.UpdateDate = getdate()
			from dbo.PRODList pl inner join dbo.List l on pl.listid = l.listid
			where l.listid = @listID
		
			if @isDebug = 1 
				print 'Delete PRODListItem ' +	convert(varchar(50),@listID)

			declare DEL_ListItemInstance cursor fast_forward for
				select pli.ListItemInstanceID from dbo.ListItem li 
					right outer join dbo.PRODlistItem pli on pli.listItemInstanceid = li.listItemInstanceid 
					where li.listItemInstanceID is null  and pli.listid = @listID
				open DEL_ListItemInstance	

				FETCH NEXT FROM  DEL_ListItemInstance INTO @listItemInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.List_list_push''s dbo.List_list_pushDelete ' +	convert(varchar(50),@listItemInstanceID)
							exec @rtnValue =dbo.List_ListItem_PushDelete @listItemInstanceID, @listID,@isDebug
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


		end
		else
			begin
			if @isDebug = 1 
				print 'Insert PRODList ' +	convert(varchar(50),@listID)

			insert into dbo.PRODList(
						ListID,
						Description,
						ShowLinkDescriptions,
						ShowShortTitle
						)
				select 
						ListID,
						Description,
						ShowLinkDescriptions,
						ShowShortTitle
				from dbo.List where listID = @listID
			end


			declare UPT_ListItemInstance cursor fast_forward for
				select ListItemInstanceID from dbo.ListItem 
					where ListID = @listID 
				open UPT_ListItemInstance	

				FETCH NEXT FROM  UPT_ListItemInstance INTO @listItemInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.List_list_push''s dbo.List_listItem_push ' +	convert(varchar(50),@listItemInstanceID)
							exec @rtnValue =dbo.List_ListItem_Push @listItemInstanceID, @listID,@updateUserID, @isDebug
							if @rtnValue <> 0 
								return @rtnValue
						FETCH NEXT FROM UPT_ListItemInstance INTO @listItemInstanceID
					END
				CLOSE UPT_ListItemInstance
			DEALLOCATE UPT_ListItemInstance
	
	end try

begin catch
	print error_message()
	 	
	return 11210
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_list_push] TO [websiteuser_role]
GO
