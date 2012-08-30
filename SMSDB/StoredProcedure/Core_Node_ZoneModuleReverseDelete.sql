IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_ZoneModuleReverseDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_ZoneModuleReverseDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--------------
--	Delete deleted ModuleInstance using Core_ModuleInstance_delete to  
			--Object, 
			--all ModuleInstanceProperty, 
			--ModuleInstance, 
-------------------
--- Delete deleted ModuleInstanceProperty

-----------------------
--delete deleted ZoneInstance 
-------


CREATE  PROCEDURE dbo.Core_Node_ZoneModuleReverseDelete
@NodeID uniqueidentifier,
@isDebug bit =0
AS
Begin

--declare @nodeid uniqueidentifier,@updateUserID varchar(50)
if @isDebug = 1 
			print 'In dbo.Core_Node_ZoneModuleReverseDelete ' +	convert(varchar(50),@NodeID)
begin try



--use dbo.Core_ModuleInstance_delete to delete object, moduleInstanceProperty, moduleInstance

declare @rtnValue int 
declare @ModuleInstanceID uniqueidentifier


declare DEL_ModuleInstance  cursor  fast_forward for 

select ModuleInstanceID from
(select ModuleInstanceID  from dbo.Zoneinstance pzi inner join dbo.ModuleInstance Pmi on pzi.zoneinstanceID = pmi.zoneInstanceID
	 where nodeid = @nodeID 
except
select ModuleInstanceID  from dbo.PRODZoneinstance pzi inner join dbo.PRODModuleInstance Pmi on pzi.zoneinstanceID = pmi.zoneInstanceID
	 where nodeid = @nodeID ) a

open  DEL_ModuleInstance

FETCH NEXT FROM  DEL_ModuleInstance INTO @ModuleInstanceID

WHILE @@FETCH_STATUS = 0
	BEGIN
		if @isDebug = 1 
			print 'In dbo.Core_Node_ZoneModuleReverseDelete:  dbo.Core_ModuleInstance_delete ' +	convert(varchar(50),@ModuleInstanceID)
		exec @rtnValue =dbo.Core_ModuleInstance_ReversePushDelete @ModuleInstanceID,@nodeID, @isDebug
		if @rtnValue <> 0 
				begin
					CLOSE DEL_ModuleInstance
					DEALLOCATE DEL_ModuleInstance
					return @rtnValue
				end
		FETCH NEXT FROM DEL_ModuleInstance INTO @ModuleInstanceID

	END
CLOSE DEL_ModuleInstance
DEALLOCATE DEL_ModuleInstance





--delete deleted ZoneInstance
if @isDebug = 1 
		print 'Delete from dbo.ZoneInstance ' +	convert(varchar(50),@NodeID)

delete from dbo.ZoneInstance where ZoneInstanceID in
(select ZoneInstanceid  from dbo.Zoneinstance  where nodeid = @nodeID 
	except
select ZoneInstanceid  from dbo.PRODZoneinstance  where nodeid = @nodeID 
)

end try
		
		
begin catch
	print error_message()
 	 
		
	return 12011
end catch



End

GO
GRANT EXECUTE ON [dbo].[Core_Node_ZoneModuleReverseDelete] TO [websiteuser_role]
GO
