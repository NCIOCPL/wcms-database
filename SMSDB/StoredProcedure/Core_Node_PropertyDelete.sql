IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_PropertyDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_PropertyDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--------------
--	Push 
--Node
--NodeProperty
--layoutDefinition
--siteNavItem
--prettyURL
-------


CREATE  PROCEDURE dbo.Core_Node_PropertyDelete
@NodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin

--declare @nodeid uniqueidentifier,@updateUserID varchar(50)

declare @rtnValue int

begin try

----Delete NodeProperty, PrettyURL, SiteNavItem, LayoutDefinition
	if @isDebug = 1 
		print 'Delete from dbo.PRODNodeProperty ' +	convert(varchar(50),@nodeID)
	delete from dbo.PRODNodeProperty where nodePropertyID in
			(select NodepropertyID from dbo.PRODNodeProperty where nodeID = @nodeID
				except
			 select NodepropertyID from dbo.nodeProperty where nodeID = @nodeID)

	if @isDebug = 1 
		print 'Delete from dbo.PRODPrettyURL' +	convert(varchar(50),@nodeID)
	delete from dbo.PRODPrettyURL where prettyURLID in
			(select PrettyURLID from dbo.PRODPrettyURL where nodeID = @nodeID
				except
			 select PrettyURLID from dbo.prettyURL where nodeID = @nodeID)

	if @isDebug = 1 
		print 'Delete from dbo.PRODSIteNavItem ' +	convert(varchar(50),@nodeID)
	delete from dbo.PRODSiteNavItem where 
			NavItemID in
			(select NavItemID from dbo.PRODSiteNavItem where nodeID = @nodeID
				except
			 select NavItemID from dbo.SiteNavItem where nodeID = @nodeID)

	if @isDebug = 1 
		print 'Delete from dbo.PRODLayoutDefinition' +	convert(varchar(50),@nodeID)
	delete from dbo.PRODLayoutDefinition  where nodeID = @nodeID and
		  convert(varchar(300), layoutTemplateID) + convert(varchar(300), contentAreaTemplateID)
			not in (select convert(varchar(300), layoutTemplateID) + convert(varchar(300), contentAreaTemplateID)
						from dbo.LayoutDefinition where nodeID = @nodeID)

		
			

end try
		
		
begin catch
	print error_message()
	 
		
	return 12010
end catch





End

GO
GRANT EXECUTE ON [dbo].[Core_Node_PropertyDelete] TO [websiteuser_role]
GO
