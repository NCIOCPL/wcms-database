IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_ZoneModulePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_ZoneModulePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_Node_ZoneModulePush
@NodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit =0
AS
Begin
	declare @moduleInstanceID uniqueidentifier, @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.Core_Node_ZoneModulePush ' +	convert(varchar(50),@NodeID)
	begin try

---ZoneInstance Push, zoneInstance Delete is done in core_Node_ZoneModuleDelete

			if @isDebug = 1 
						print 'Update PRODZoneInstance '
				update pzi
					set pzi.CanInherit = zi.CanInherit,
						pzi.TemplateZoneID = zi.TemplateZoneID,
						pzi.UpdateUserID = @updateUserID,
						pzi.UpdateDate = getdate() 
					from dbo.PRODZoneInstance pzi 
						inner join DBO.ZoneInstance zi on pzi.zoneInstanceID = zi.zoneInstanceID
					where  pzi.nodeID = @NodeID 

			insert into dbo.PRODZoneInstance (
					NodeID,
					ZoneInstanceID,
					TemplateZoneID,
					CanInherit,
					CreateUserID,
					CreateDate,
					UpdateUserID,
					UpdateDate)
				select 
					zi.NodeID,
					zi.ZoneInstanceID,
					zi.TemplateZoneID,
					zi.CanInherit,
					@UpdateUserID,
					getdate(),
					@UpdateUserID,
					getdate()
				from DBO.ZoneInstance zi left outer join dbo.PRODZoneinstance pzi 
						on zi.nodeid = pzi.nodeid and zi.zoneinstanceID = pzi.zoneInstanceID
				where zi.nodeid = @nodeid and pzi.zoneInstanceid is null
					




		--use dbo.Core_ModuleInstance_delete to delete object, moduleInstanceProperty, moduleInstance


		declare DEL_ModuleInstance  cursor  fast_forward for 

		select ModuleInstanceID from
		(select ModuleInstanceID  from dbo.PRODZoneinstance pzi inner join dbo.PRODModuleInstance Pmi on pzi.zoneinstanceID = pmi.zoneInstanceID
			 where nodeid = @nodeID 
			except
		select ModuleInstanceID  from dbo.Zoneinstance pzi inner join dbo.ModuleInstance Pmi on pzi.zoneinstanceID = pmi.zoneInstanceID
			 where nodeid = @nodeID ) a

		open  DEL_ModuleInstance

		FETCH NEXT FROM  DEL_ModuleInstance INTO @ModuleInstanceID

		WHILE @@FETCH_STATUS = 0
			BEGIN
				if @isDebug = 1 
					print 'In dbo.Core_Node_ZoneModuleDelete:  dbo.Core_ModuleInstance_delete ' +	convert(varchar(50),@ModuleInstanceID)
				exec @rtnValue =dbo.Core_ModuleInstance_PushDelete @ModuleInstanceID,@nodeID, @isDebug
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
				print 'Delete from dbo.PRODZoneInstance ' +	convert(varchar(50),@NodeID)

		delete from dbo.PRODZoneInstance where ZoneInstanceID in
		(select ZoneInstanceid  from dbo.PRODZoneinstance  where nodeid = @nodeID 
			except
		select ZoneInstanceid  from dbo.Zoneinstance  where nodeid = @nodeID )


		









		declare UPT_ModuleInstance cursor fast_forward for
				select moduleInstanceID from dbo.moduleInstance mi 
					inner join dbo.zoneInstance zi on zi.zoneInstanceID = mi.zoneInstanceID
					where nodeID = @nodeID 
				open UPT_ModuleInstance	

				FETCH NEXT FROM  UPT_ModuleInstance INTO @ModuleInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.Core_Node_ZoneModulePush''s dbo.Core_ModuleInstance_Push ' +	convert(varchar(50),@ModuleInstanceID)
							exec @rtnValue =dbo.Core_ModuleInstance_Push @ModuleInstanceID, @nodeID,@updateUserID, @isDebug
							if @rtnValue <> 0 
								begin
									CLOSE UPT_ModuleInstance
									DEALLOCATE UPT_ModuleInstance
									return @rtnValue
								end
						FETCH NEXT FROM UPT_ModuleInstance INTO @ModuleInstanceID
					END
				CLOSE UPT_ModuleInstance
			DEALLOCATE UPT_ModuleInstance
	
	end try

begin catch
	print error_message()
	 
		
	return 11810
end catch


End

GO
GRANT EXECUTE ON [dbo].[Core_Node_ZoneModulePush] TO [websiteuser_role]
GO
