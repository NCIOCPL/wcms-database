IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_listItem_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_listItem_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.List_listItem_ReversePush
@listItemInstanceID uniqueidentifier,
@ListID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit =0
AS
Begin
	declare @listItemID uniqueIdentifier,@Typename varchar(50)
	declare @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_listItem_ReversePush ' +	convert(varchar(50),@listItemInstanceID)
	begin try

	select @ListItemID = listItemId , @typename = typename
		from dbo.PRODListItem li 
			inner join dbo.ListItemType lit on li.listITemtypeid = lit.listItemTypeid
		where listItemInstanceid = @listItemInstanceid 

	if exists (select 1 from dbo.ListItem where ListItemInstanceID = @listItemInstanceID)
		begin
		if @isDebug = 1 
			print 'Update ListItem ' +	convert(varchar(50),@listItemID)
		update li
				set li.ListItemID = pli.ListItemID,
					li.ListItemTypeID =  pli.LIstITemTypeID,
					li.IsFeatured = pli.isFeatured,
					li.Priority = pli.Priority,
					li.CreateUserID =@updateUserid,
					li.CreateDate = Getdate(),
					li.UpdateUserID = @updateUserid,
					li.UpdateDate = getdate(),
					li.OverriddenTitle = pli.overriddenTitle,
					li.OverriddenShortTitle = pli.OverriddenShorttitle,
					li.OverriddenDescription = pli.OverriddenDescription,
					li.OverriddenAnchor = pli.OverriddenAnchor,
					li.OverriddenQuery = pli.OverriddenQuery,
					li.FileSize = pli.FileSize,
					li.FileIcon = pli.FileIcon,
					li.SupplementalText = pli.SupplementalText
				from dbo.ListItem li inner join dbo.PRODListITem pli on pli.ListItemInstanceID = li.ListItemInstanceID
			where li.ListItemInstanceID = @listItemInstanceID
		end
		else
			begin
					select @ListItemID = listItemId , @typename = typename
						from dbo.PRODListItem li 
							inner join dbo.ListItemType lit on li.listITemtypeid = lit.listItemTypeid
						where listItemInstanceid = @listItemInstanceid 

					print 'new listItem type ' + @typeName

					if (@typename = 'internalLink' and 
						 exists (select 1 from dbo.Node where nodeid  = @ListItemID))
						or @typename <>'internalLink'

					begin

								if @isDebug = 1 
									print 'Insert ListItem ' +	convert(varchar(50),@listItemID)
								insert into dbo.ListItem(
											ListItemInstanceID,
											ListID,
											ListItemID,
											ListItemTypeID,
											IsFeatured,
											Priority,
											OverriddenTitle,
											OverriddenShortTitle,
											OverriddenDescription,
											OverriddenAnchor,
											OverriddenQuery,
											FileSize,
											FileIcon,
											SupplementalText
											)
									select 
											ListItemInstanceID,
											ListID,
											ListItemID,
											ListItemTypeID,
											IsFeatured,
											Priority,
											OverriddenTitle,
											OverriddenShortTitle,
											OverriddenDescription,
											OverriddenAnchor,
											OverriddenQuery,
											FileSize,
											FileIcon,
											SupplementalText
									from dbo.PRODListITem where ListItemInstanceID = @listItemInstanceID
					end
			end


	
	end try

begin catch
	print error_message()
	 	
	return 11111
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_listItem_ReversePush] TO [websiteuser_role]
GO
