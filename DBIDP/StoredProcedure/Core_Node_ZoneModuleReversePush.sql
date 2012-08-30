IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_ZoneModuleReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_ZoneModuleReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_Node_ZoneModuleReversePush
@NodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit =0
AS
Begin
	declare @moduleInstanceID uniqueidentifier, @rtnvalue int
	if @isDebug = 1 
			print 'In dbo.Core_Node_ZoneModuleReversePush ' +	convert(varchar(50),@NodeID)
	begin try



---ZoneInstance Push, zoneInstance Delete is done in core_Node_ZoneModuleDelete

			if @isDebug = 1 
						print 'Update PRODZoneInstance '
				update zi
					set zi.CanInherit = pzi.CanInherit,
						zi.TemplateZoneID = pzi.TemplateZoneID,
						zi.UpdateUserID = @updateUserID,
						zi.UpdateDate = getdate() 
					from dbo.ZoneInstance zi 
						inner join DBO.PRODZoneInstance pzi on pzi.zoneInstanceID = zi.zoneInstanceID
					where  zi.nodeID = @NodeID 

			insert into dbo.ZoneInstance (
					NodeID,
					ZoneInstanceID,
					TemplateZoneID,
					CanInherit,
					CreateUserID,
					CreateDate,
					UpdateUserID,
					UpdateDate)
				select 
					pzi.NodeID,
					pzi.ZoneInstanceID,
					pzi.TemplateZoneID,
					pzi.CanInherit,
					@UpdateUserID,
					getdate(),
					@UpdateUserID,
					getdate()
				from DBO.PRODZoneInstance pzi left outer join dbo.Zoneinstance zi 
						on zi.nodeid = pzi.nodeid and zi.zoneinstanceID = pzi.zoneInstanceID
				where pzi.nodeid = @nodeid and zi.zoneInstanceid is null
					


		--use dbo.Core_ModuleInstance_delete to delete object, moduleInstanceProperty, moduleInstance


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
		select ZoneInstanceid  from dbo.PRODZoneinstance  where nodeid = @nodeID )


		









		declare UPT_ModuleInstance cursor fast_forward for
				select moduleInstanceID from dbo.PRODmoduleInstance mi 
					inner join dbo.PRODzoneInstance zi on zi.zoneInstanceID = mi.zoneInstanceID
					where nodeID = @nodeID 
				open UPT_ModuleInstance	

				FETCH NEXT FROM  UPT_ModuleInstance INTO @ModuleInstanceID

				WHILE @@FETCH_STATUS = 0
					BEGIN
							if @isDebug = 1 
								print 'In dbo.Core_Node_ZoneModuleReversePush''s dbo.Core_ModuleInstance_ReversePush ' +	convert(varchar(50),@ModuleInstanceID)
							exec @rtnValue =dbo.Core_ModuleInstance_ReversePush @ModuleInstanceID, @nodeID,@updateUserID, @isDebug
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
	 
		
	return 11811
end catch


End

GO
GRANT EXECUTE ON [dbo].[Core_Node_ZoneModuleReversePush] TO [websiteuser_role]
GO
