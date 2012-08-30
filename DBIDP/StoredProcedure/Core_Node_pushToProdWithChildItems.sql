IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_pushToProdWithChildItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_pushToProdWithChildItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




CREATE  PROCEDURE dbo.Core_Node_pushToProdWithChildItems
@NodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin

--declare @nodeid uniqueidentifier,@updateUserID varchar(50)


begin try
		declare @rtnvalue int
			
		
		
						--- ----Delete  
						--	Node 
						--	NodeProperty, 
						--	PrettyURL, 
						--	SiteNavItem, 
						--	LayoutDefinition
						if @isDebug = 1 
							print 'Core_node_PropertyDelete  ' +	convert(varchar(50),@nodeID)
						exec @rtnValue = dbo.Core_node_PropertyDelete @nodeID, @updateUserID, @isDebug
						if @rtnvalue <>  0 
							begin
								
								return @rtnvalue
							end

							-----------------
							--	Delete  based on NodeID and deleted
							--Object, 
							--ModuleInstanceProperty, 
							--ModuleInstance, 
							--ZoneInstance
							-------
						if @isDebug = 1 
							print 'Core_Node_ZoneModuledelete ' +	convert(varchar(50),@nodeID)	

						exec @rtnValue =dbo.Core_Node_ZoneModuledelete @NodeID, @isdebug
						if @rtnvalue <>  0 
							begin
								
								return @rtnvalue
							end

						---Delete Node
						if exists (select 1 from dbo.PRODNode where nodeID = @nodeID) and not exists (select 1 from node where nodeid = @nodeID)
								begin
									if @isDebug = 1 
										print 'delete Orphaned Objects for NOde ' +	convert(varchar(50),@nodeID)	

									declare @objectid uniqueidentifier
									declare DEL_Object  cursor  fast_forward for 

									select Objectid from
									(select Objectid  from dbo.PRODObject
										 where ownerid = @nodeID 
										except
									select Objectid  from dbo.Object
										 where ownerid = @nodeID ) a

									open  DEL_Object

									FETCH NEXT FROM  DEL_Object INTO @Objectid

									WHILE @@FETCH_STATUS = 0
										BEGIN
											if @isDebug = 1 
												print 'In dbo.Core_Node_pushToProdWithChildItems: dbo.Core_object_pushDelete ' +	convert(varchar(50),@Objectid)
											exec @rtnValue =dbo.Core_Object_PushDelete @Objectid, @isDebug
											if @rtnValue <> 0 
													begin
														CLOSE DEL_Object
														DEALLOCATE DEL_Object
														return @rtnValue
													end
											FETCH NEXT FROM DEL_Object INTO @Objectid

										END
									CLOSE DEL_Object
									DEALLOCATE DEL_Object
			
									if @isDebug = 1 
										print 'delete from dbo.PRODNode ' +	convert(varchar(50),@nodeID)	
									delete from dbo.PRODNode where nodeID = @nodeID
								end		
						else
								begin
										-----Update, insert 
										--Node, 
										--NodeProperty, 
										--LayoutDefinition, 
										--SiteNavItem, 
										--PrettyURL
									if @isDebug = 1 
										print 'Core_Node_PropertyPush ' +	convert(varchar(50),@nodeID)
									exec @rtnvalue = dbo.core_node_propertyPush @nodeID, @updateUserID, @isDebug
									if @rtnvalue <>  0 
										begin
											
											return @rtnvalue
										end
										

									----Update Insert  based on NodeID
									--Module, 
									--ZoneInstance, 
									--Object, 
									--ModuleInstance, 
									--ModuleInstanceProperty
									if @isDebug = 1 
											print 'dbo.core_node_ZoneModulePush ' +	convert(varchar(50),@nodeID)
									exec @rtnvalue = dbo.core_node_ZoneModulePush @nodeID, @updateUserID, @isDebug
									if @rtnvalue <>  0 
										begin
											
											return @rtnvalue
										end
									
								end
		
	
end try
		
		
begin catch
	print error_message()
	if @@trancount = 1 
		
	return 12010
end catch





End

GO
GRANT EXECUTE ON [dbo].[Core_Node_pushToProdWithChildItems] TO [websiteuser_role]
GO
