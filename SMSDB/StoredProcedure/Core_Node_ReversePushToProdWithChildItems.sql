IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_ReversePushToProdWithChildItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_ReversePushToProdWithChildItems]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




CREATE  PROCEDURE dbo.Core_Node_ReversePushToProdWithChildItems
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
							print 'Core_Node_PropertyReverseDelete  ' +	convert(varchar(50),@nodeID)
						exec @rtnValue = dbo.Core_Node_PropertyReverseDelete @nodeID, @updateUserID, @isDebug
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
							print 'Core_Node_ZoneModuleReverseDelete ' +	convert(varchar(50),@nodeID)	

						exec @rtnValue =dbo.Core_Node_ZoneModuleReverseDelete @NodeID, @isdebug
						if @rtnvalue <>  0 
							begin
								
								return @rtnvalue
							end

						---Delete Node
						if exists (select 1 from dbo.Node where nodeID = @nodeID) and not exists (select 1 from PRODnode where nodeid = @nodeID)
								begin
									if @isDebug = 1 
										print 'delete Orphaned Objects for NOde ' +	convert(varchar(50),@nodeID)	

									declare @objectid uniqueidentifier
									declare DEL_Object  cursor  fast_forward for 

									select Objectid from
									(select Objectid  from dbo.Object
										 where ownerid = @nodeID 
										except
									select Objectid  from dbo.PRODObject
										 where ownerid = @nodeID ) a

									open  DEL_Object

									FETCH NEXT FROM  DEL_Object INTO @Objectid

									WHILE @@FETCH_STATUS = 0
										BEGIN
											if @isDebug = 1 
												print 'In dbo.Core_Node_ReversePushToProdWithChildItems: dbo.Core_object_ReversePushDelete ' +	convert(varchar(50),@Objectid)
											exec @rtnValue =dbo.Core_Object_ReversePushDelete @Objectid, @isDebug
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
										print 'delete from dbo.Node ' +	convert(varchar(50),@nodeID)	
									delete from dbo.Node where nodeID = @nodeID
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
										print 'Core_Node_PropertyReversePush ' +	convert(varchar(50),@nodeID)
									exec @rtnvalue = dbo.Core_Node_PropertyReversePush @nodeID, @updateUserID, @isDebug
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
											print 'dbo.Core_Node_ZoneModuleReversePush ' +	convert(varchar(50),@nodeID)
									exec @rtnvalue = dbo.Core_Node_ZoneModuleReversePush @nodeID, @updateUserID, @isDebug
									if @rtnvalue <>  0 
										begin
											
											return @rtnvalue
										end
									
								end
		
	
end try
		
		
begin catch
	print error_message()
		
	return 12011
end catch





End

GO
GRANT EXECUTE ON [dbo].[Core_Node_ReversePushToProdWithChildItems] TO [websiteuser_role]
GO
