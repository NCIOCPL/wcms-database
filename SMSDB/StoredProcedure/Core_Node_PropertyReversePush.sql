IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_PropertyReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_PropertyReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

	-----Update, insert 
	--Node, 
	--NodeProperty, 
	--LayoutDefinition, 
	--SiteNavItem, 
	--PrettyURL

CREATE  PROCEDURE dbo.Core_Node_PropertyReversePush
@NodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin

declare @rtnValue int

begin try

-----Update, insert Node, NodeProperty, LayoutDefinition, SiteNavItem, PrettyURL

			if exists (select 1 from dbo.node where nodeid = @nodeid) 
				begin
					if @isDebug = 1 
						print 'Update Node ' +	convert(varchar(50),@NodeID)
					update n
					set n.Title = pn.Title,
						n.ShortTitle = pn.ShortTitle,
						n.Description = pn.Description,
						n.ParentNodeID = pn.ParentNodeID,
						n.showInNavigation = pn.showInNavigation,
						n.ShowInBreadCrumbs = pn.ShowInBreadCrumbs,
						n.Priority = pn.Priority,
						n.DisplayPostedDate  = pn.DisplayPostedDate,
						n.DisplayUpdateDate = pn.DisplayUpdateDate,
						n.DisplayReviewDate = pn.DisplayReviewDate,
						n.DisplayExpirationDate = pn.DisplayExpirationDate,
						n.DisplayDateMode = pn.DisplayDateMode,
						n.UpdateUserID = @updateUserID,
						n.UpdateDate = getdate() 
						from dbo.PRODNode Pn 
							inner join node n on Pn.nodeid = n.nodeid
						where pn.nodeid = @nodeID
				end
			else
				begin
					if @isDebug = 1 
						print 'Insert Node ' +	convert(varchar(50),@NodeID)
					insert into dbo.node (NodeID,
						Title,
						ShortTitle,
						Description,
						ParentNodeID,
						ShowInNavigation,
						ShowInBreadCrumbs,
						Priority,
						DisplayPostedDate ,
						DisplayUpdateDate ,
						DisplayReviewDate ,
						DisplayExpirationDate,
						DisplayDateMode,
						CreateUserID,
						CreateDate,
						UpdateUserID,
						UpdateDate)
					select	NodeID,
						Title,
						ShortTitle,
						Description,
						ParentNodeID,
						ShowInNavigation,
						ShowInBreadCrumbs,
						Priority,
						DisplayPostedDate ,
						DisplayUpdateDate ,
						DisplayReviewDate ,
						DisplayExpirationDate,
						DisplayDateMode,
						@UpdateUserID,
						getdate(),
						@UpdateUserID,
						getdate()
					from dbo.PRODnode	
						where nodeid = @nodeID
				End
		
		if @isDebug = 1 
				print 'Update NodeProperty ' +	convert(varchar(50),@NodeID)
		update np
			set np.PropertyTemplateID = pnp.PropertyTemplateID,
				np.PropertyValue = pnp.PropertyValue,
				np.UpdateUserID = @updateUserID,
				np.UpdateDate = getdate() 
			from dbo.PRODNodeproperty Pnp 
					inner join nodeproperty np on Pnp.nodepropertyid = np.nodepropertyid 
			where pnp.nodeid= @nodeid
		
		if @isDebug = 1 
				print 'Insert NodeProperty ' +	convert(varchar(50),@NodeID)
		insert into dbo.nodeProperty (
				NodePropertyID,
				NodeID,
				PropertyTemplateID,
				PropertyValue,
				CreateUserID,
				CreateDate,
				UpdateUserID,
				UpdateDate)
			select 
				NodePropertyID,
				NodeID,
				PropertyTemplateID,
				PropertyValue,
				@UpdateUserID,
				getdate(),
				@UpdateUserID,
				getdate()
			from dbo.PRODnodeProperty 
				where nodeid = @nodeID 
					and nodepropertyID not in (select nodepropertyid from dbo.NodeProperty)

	


	
		if @isDebug = 1 
				print 'Update LayoutDefinition ' +	convert(varchar(50),@NodeID)
		update ld
			set ld.LayoutTemplateID = pld.LayoutTemplateID,
				ld.ContentAreaTemplateID = pld.ContentAreaTemplateID,
				ld.UpdateUserID = @updateUserID,
				ld.UpdateDate = getdate() 
			from dbo.PRODLayoutDefinition Pld 
					inner join dbo.LayoutDefinition ld on Pld.nodeid = ld.nodeid
				where pld.nodeid = @nodeID

		if @isDebug = 1 
				print 'Insert LayoutDefinition ' +	convert(varchar(50),@NodeID)
		insert into dbo.LayoutDefinition (
				NodeID,
				LayoutTemplateID,
				ContentAreaTemplateID,
				CreateUserID,
				CreateDate,
				UpdateUserID,
				UpdateDate)
			select 
				NodeID,
				LayoutTemplateID,
				ContentAreaTemplateID,
				@UpdateUserID,
				getdate(),
				@UpdateUserID,
				getdate()
			from dbo.PRODLayoutDefinition 
			where nodeid =  @nodeID 
				and nodeID not in (select nodeid from dbo.LayoutDefinition)
			
		

		if @isDebug = 1 
				print 'Update SiteNavItem ' +	convert(varchar(50),@NodeID)
	
		update sni
			set sni.DisplayName = psni.DisplayName,
				sni.NavCategory = psni.NavCategory,
				sni.NavImg = psni.NavImg,
				sni.UpdateUserID = @updateUserID,
				sni.UpdateDate = getdate() 
			from dbo.PRODSiteNavItem psni 
				inner join dbo.SiteNavItem sni on psni.NavItemID = sni.NavItemID
			where  psni.nodeid = @nodeID 


		if @isDebug = 1 
				print 'Insert SIteNavItem' +	convert(varchar(50),@NodeID)

		insert into dbo.SiteNavItem (
				NodeID,
				NavItemID,
				DisplayName,
				NavCategory,
				NavImg,
				CreateUserID,
				CreateDate,
				UpdateUserID,
				UpdateDate)
			select 
				NodeID,
				NavItemID,
				DisplayName,
				NavCategory,
				NavImg,
				@UpdateUserID,
				getdate(),
				@UpdateUserID,
				getdate()
			from dbo.PRODSiteNavItem 
			where nodeid =  @nodeID 
				and NavItemID not in (select NavItemid from dbo.SiteNavItem)

	
		if @isDebug = 1 
				print 'Update PrettyURL ' +	convert(varchar(50),@NodeID)

		update pu
			set pu.prettyURL = ppu.PrettyURL,
				pu.realURL = ppu.realURL,
				pu.isPrimary = ppu.isPrimary,
				pu.UpdateUserID = @updateUserID,
				pu.UpdateDate = getdate() 
			from dbo.PRODPrettyURL ppu 
				inner join dbo.prettyURL pu on ppu.prettyURLID = pu.prettyURLID
			where  ppu.nodeid = @nodeID 

		if @isDebug = 1 
				print 'Insert PrettyURL ' +	convert(varchar(50),@NodeID)

		insert into dbo.PrettyURL (
				NodeID,
				prettyURLID,
				prettyURL,
				realURL,
				isPrimary,
				CreateUserID,
				CreateDate,
				UpdateUserID,
				UpdateDate)
			select 
				NodeID,
				prettyURLID,
				prettyURL,
				realURL,
				isPrimary,
				@UpdateUserID,
				getdate(),
				@UpdateUserID,
				getdate()
			from dbo.PRODprettyURL 
			where nodeid =  @nodeID 
				and prettyURLID not in (select prettyURLID from dbo.PrettyURL)

end try
		
begin catch
	print error_message()
	return 12011
end catch





End

GO
GRANT EXECUTE ON [dbo].[Core_Node_PropertyReversePush] TO [websiteuser_role]
GO
