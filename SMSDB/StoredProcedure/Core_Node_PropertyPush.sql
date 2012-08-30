IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_PropertyPush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_PropertyPush]
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

CREATE  PROCEDURE dbo.Core_Node_PropertyPush
@NodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin

declare @rtnValue int

begin try

-----Update, insert Node, NodeProperty, LayoutDefinition, SiteNavItem, PrettyURL

			if exists (select 1 from dbo.PRODnode where nodeid = @nodeid) 
				begin
					if @isDebug = 1 
						print 'Update PRODNode ' +	convert(varchar(50),@NodeID)
					update Pn
					set Pn.Title = n.Title,
						Pn.ShortTitle = n.ShortTitle,
						Pn.Description = n.Description,
						Pn.ParentNodeID = n.ParentNodeID,
						Pn.showInNavigation = n.showInNavigation,
						Pn.ShowInBreadCrumbs = n.ShowInBreadCrumbs,
						Pn.Priority = n.Priority,
						Pn.DisplayPostedDate  = n.DisplayPostedDate,
						Pn.DisplayUpdateDate = n.DisplayUpdateDate,
						Pn.DisplayReviewDate = n.DisplayReviewDate,
						Pn.DisplayExpirationDate = n.DisplayExpirationDate,
						Pn.DisplayDateMode = n.DisplayDateMode,
						Pn.UpdateUserID = @updateUserID,
						Pn.UpdateDate = getdate() 
						from dbo.PRODNode Pn 
							inner join node n on Pn.nodeid = n.nodeid
						where pn.nodeid = @nodeID
				end
			else
				begin
					if @isDebug = 1 
						print 'Insert PRODNode ' +	convert(varchar(50),@NodeID)
					insert into dbo.PRODnode (NodeID,
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
					from dbo.node	
						where nodeid = @nodeID
				End
		
		if @isDebug = 1 
				print 'Update PRODNodeProperty ' +	convert(varchar(50),@NodeID)
		update Pnp
			set Pnp.PropertyTemplateID = np.PropertyTemplateID,
				Pnp.PropertyValue = np.PropertyValue,
				Pnp.UpdateUserID = @updateUserID,
				Pnp.UpdateDate = getdate() 
			from dbo.PRODNodeproperty Pnp 
					inner join nodeproperty np on Pnp.nodepropertyid = np.nodepropertyid 
			where pnp.nodeid= @nodeid
		
		if @isDebug = 1 
				print 'Insert PRODNodeProperty ' +	convert(varchar(50),@NodeID)
		insert into dbo.PRODnodeProperty (
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
			from dbo.nodeProperty 
				where nodeid = @nodeID 
					and nodepropertyID not in (select nodepropertyid from dbo.PRODNodeProperty)

	


	
		if @isDebug = 1 
				print 'Update PRODLayoutDefinition ' +	convert(varchar(50),@NodeID)
		update Pld
			set Pld.LayoutTemplateID = ld.LayoutTemplateID,
				Pld.ContentAreaTemplateID = ld.ContentAreaTemplateID,
				Pld.UpdateUserID = @updateUserID,
				Pld.UpdateDate = getdate() 
			from dbo.PRODLayoutDefinition Pld 
					inner join dbo.LayoutDefinition ld on Pld.nodeid = ld.nodeid
				where pld.nodeid = @nodeID

		if @isDebug = 1 
				print 'Insert PRODLayoutDefinition ' +	convert(varchar(50),@NodeID)
		insert into dbo.PRODLayoutDefinition (
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
			from dbo.LayoutDefinition 
			where nodeid =  @nodeID 
				and nodeID not in (select nodeid from dbo.PRODLayoutDefinition)
			
		

		if @isDebug = 1 
				print 'Update PRODSiteNavItem ' +	convert(varchar(50),@NodeID)
	
		update psni
			set psni.DisplayName = sni.DisplayName,
				psni.UpdateUserID = @updateUserID,
				psni.NavCategory = sni.NavCategory,
				psni.NavImg = sni.NavImg,
				psni.UpdateDate = getdate() 
			from dbo.PRODSiteNavItem psni 
				inner join dbo.SiteNavItem sni on psni.NavItemID = sni.NavItemID
			where  psni.nodeid = @nodeID 


		if @isDebug = 1 
				print 'Insert PRODSIteNavItem' +	convert(varchar(50),@NodeID)

		insert into dbo.PRODSiteNavItem (
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
			from dbo.SiteNavItem 
			where nodeid =  @nodeID 
				and NavItemID not in (select NavItemid from dbo.PRODSiteNavItem)

	
		if @isDebug = 1 
				print 'Update PRODPrettyURL ' +	convert(varchar(50),@NodeID)

		update ppu
			set ppu.prettyURL = pu.PrettyURL,
				ppu.realURL = pu.realURL,
				ppu.isPrimary = pu.isPrimary,
				ppu.UpdateUserID = @updateUserID,
				ppu.UpdateDate = getdate() 
			from dbo.PRODPrettyURL ppu 
				inner join dbo.prettyURL pu on ppu.prettyURLID = pu.prettyURLID
			where  ppu.nodeid = @nodeID 

		if @isDebug = 1 
				print 'Insert PRODPrettyURL ' +	convert(varchar(50),@NodeID)

		insert into dbo.PRODPrettyURL (
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
			from dbo.prettyURL 
			where nodeid =  @nodeID 
				and prettyURLID not in (select prettyURLID from dbo.PRODPrettyURL)

end try
		
begin catch
	print error_message()
	return 12010
end catch





End

GO
GRANT EXECUTE ON [dbo].[Core_Node_PropertyPush] TO [websiteuser_role]
GO
