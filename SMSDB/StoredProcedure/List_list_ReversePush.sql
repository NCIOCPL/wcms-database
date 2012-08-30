IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_list_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_list_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.List_list_ReversePush
@listID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit =0
AS
Begin
	declare @listItemInstanceID uniqueidentifier, @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_list_ReversePush ' +	convert(varchar(50),@listID)
	begin try

	if exists (select 1 from dbo.List where listID = @listID)
		begin
			if @isDebug = 1 
				print 'Update List ' +	convert(varchar(50),@listID)
			update l
				set 
				l.Description = pl.description,
				l.ShowLinkDescriptions = pl.ShowLinkDescriptions,
				l.ShowShortTitle = pl.showShorttitle,
				l.CreateUserID =  @updateUserID,
				l.CreateDate = getdate(),
				l.UpdateUserID = @updateuserid,
				l.UpdateDate = getdate()
			from dbo.List l inner join dbo.PRODList pl on pl.listid = l.listid
			where l.listid = @listID
		
			if @isDebug = 1 
				print 'Delete ListItem ' +	convert(varchar(50),@listID)

			declare DEL_ListItemInstance cursor fast_forward for
				select li.ListItemInstanceID from dbo.ListItem li 
					left outer join dbo.PRODlistItem pli on pli.listItemInstanceid = li.listItemInstanceid 
					where pli.listItemInstanceID is null  and li.listid = @listID
				open DEL_ListItemInstance	

				FETCH NEXT FROM  DEL_ListItemInstance INTO @listItemInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.List_list_ReversePush''s dbo.List_list_ReversePushDelete ' +	convert(varchar(50),@listItemInstanceID)
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


		end
		else
			begin
			if @isDebug = 1 
				print 'Insert List ' +	convert(varchar(50),@listID)

			insert into dbo.List(
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
				from dbo.PRODList where listID = @listID
			end


			declare UPT_ListItemInstance cursor fast_forward for
				select ListItemInstanceID from dbo.PRODListItem 
					where ListID = @listID 
				open UPT_ListItemInstance	

				FETCH NEXT FROM  UPT_ListItemInstance INTO @listItemInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.List_list_ReversePush''s dbo.List_listItem_ReversePush ' +	convert(varchar(50),@listItemInstanceID)
							exec @rtnValue =dbo.List_ListItem_ReversePush @listItemInstanceID, @listID,@updateUserID, @isDebug
							if @rtnValue <> 0 
								return @rtnValue
						FETCH NEXT FROM UPT_ListItemInstance INTO @listItemInstanceID
					END
				CLOSE UPT_ListItemInstance
			DEALLOCATE UPT_ListItemInstance
	
	end try

begin catch
	print error_message()
	 	
	return 11211
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_list_ReversePush] TO [websiteuser_role]
GO
