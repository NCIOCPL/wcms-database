IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[List_listItem_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[List_listItem_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE dbo.List_listItem_push
@listItemInstanceID uniqueidentifier,
@ListID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit =0
AS
Begin
	declare @listItemID uniqueIdentifier,@Typename varchar(50)
	declare @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.List_listItem_push ' +	convert(varchar(50),@listItemInstanceID)
	begin try

	select @ListItemID = listItemId , @typename = typename
		from dbo.ListItem li 
			inner join dbo.ListItemType lit on li.listITemtypeid = lit.listItemTypeid
		where listItemInstanceid = @listItemInstanceid 

	if exists (select 1 from dbo.PRODListItem where ListItemInstanceID = @listItemInstanceID)
		begin
		if @isDebug = 1 
			print 'Update PRODListItem ' +	convert(varchar(50),@listItemID)
		update Pli
				set pli.ListItemID = li.ListItemID,
					pli.ListItemTypeID =  li.LIstITemTypeID,
					pli.IsFeatured = li.isFeatured,
					pli.Priority = li.Priority,
					pli.CreateUserID =@updateUserid,
					pli.CreateDate = Getdate(),
					pli.UpdateUserID = @updateUserid,
					pli.UpdateDate = getdate(),
					pli.OverriddenTitle = li.overriddenTitle,
					pli.OverriddenShortTitle = li.OverriddenShorttitle,
					pli.OverriddenDescription = li.OverriddenDescription,
					pli.OverriddenAnchor = li.OverriddenAnchor,
					pli.OverriddenQuery = li.OverriddenQuery,
					pli.FileSize = li.FileSize,
					pli.FileIcon = li.FileIcon,
					pli.SupplementalText = li.SupplementalText
				from dbo.PRODListItem pli inner join dbo.ListITem li on pli.ListItemInstanceID = li.ListItemInstanceID
			where pli.ListItemInstanceID = @listItemInstanceID
		end
		else
			begin
					select @ListItemID = listItemId , @typename = typename
						from dbo.ListItem li 
							inner join dbo.ListItemType lit on li.listITemtypeid = lit.listItemTypeid
						where listItemInstanceid = @listItemInstanceid 

					print 'new listItem type ' + @typeName

					if (@typename = 'internalLink' and 
						 exists (select 1 from dbo.PRODNode where nodeid  = @ListItemID))
						or @typename <>'internalLink'

					begin

								if @isDebug = 1 
									print 'Insert PRODListItem ' +	convert(varchar(50),@listItemID)
								insert into dbo.PRODListItem(
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
									from dbo.ListITem where ListItemInstanceID = @listItemInstanceID
					end
			end


	
	end try

begin catch
	print error_message()
	 	
	return 11110
end catch


End

GO
GRANT EXECUTE ON [dbo].[List_listItem_push] TO [websiteuser_role]
GO
