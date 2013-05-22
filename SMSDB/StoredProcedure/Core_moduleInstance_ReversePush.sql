IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_moduleInstance_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_moduleInstance_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_moduleInstance_ReversePush
@moduleInstanceID uniqueidentifier,
@nodeID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
--declare @moduleInstanceID uniqueidentifier,@updateUserID varchar(50)

begin try

----Update Insert  
--Module, 
--ZoneInstance, 
--Object, 
--ModuleInstance, 
--ModuleInstanceProperty
	
	if @isDebug = 1 
			print 'In dbo.Core_moduleInstance_ReversePush ' +	convert(varchar(50),@ModuleInstanceID)
	declare @moduleID uniqueidentifier, @zoneInstanceID uniqueIdentifier, @objectID uniqueIdentifier, @rtnValue int

	select	@moduleID = moduleID, 
			@ZoneInstanceID = ZoneInstanceID, 
			@objectID= objectid 
		from dbo.PRODModuleInstance where moduleInstanceID = @moduleInstanceID
	
	declare @isShared bit , @ownerid uniqueidentifier

	select @isShared = isShared, @ownerid = ownerid
		from DBO.PRODobject where objectid= @objectid

	if @isShared = 1 and @ownerid = @nodeid
		if not exists (select 1 from dbo.node where nodeid = @nodeid)
			begin 
				print 'shared object''s nodeid = ownerid, but owner not on Live, do not push the moduleinstance'
				return 0
			end



--	if @isDebug = 1 
--			print 'Core_module_ReversePush ' +	convert(varchar(50),@ModuleID)
--	exec @rtnValue = dbo.Core_module_ReversePush @moduleID,@updateUserID,@isDebug
--	if @rtnValue <> 0
--			return @rtnValue
--	
--	if @isDebug = 1 
--			print 'Core_ZoneInstance_ReversePush ' +	convert(varchar(50),@ZoneInstanceID)
--	exec @rtnValue = dbo.Core_ZoneInstance_ReversePush @ZoneInstanceID,@updateUserID, @isdebug
--	if @rtnValue <> 0
--			return @rtnValue
	
-- Only push 
	if exists (select 1 from DBO.PRODobject o 
					inner join dbo.PRODModuleinstance mi on o.objectid = mi.objectid 
					where o.objectid = @objectID and ownerID = @nodeID
				)
		begin
			if @isDebug = 1 
				print 'Core_Object_ReversePush ' +	convert(varchar(50),@ObjectID)
			exec @rtnValue = dbo.Core_Object_ReversePush @ObjectID,@nodeid, @updateUserID, @isDebug
			if @rtnValue <> 0
				return @rtnValue
		end
				

	if @isDebug = 1 
			print 'Update ModuleInstance ' +	convert(varchar(50),@ModuleInstanceID)

	update mi
		set mi.ZoneInstanceID =pmi.ZoneInstanceID ,
			mi.moduleID = pmi.moduleID,
			mi.priority = pmi.priority ,
			mi.objectID = pmi.ObjectID,
			mi.UpdateUserID = @updateUserID,
			mi.UpdateDate = getdate() 
			from dbo.PRODmoduleInstance pmi
				inner join dbo.ModuleInstance mi on pmi.moduleInstanceID = mi.moduleInstanceID
			where  pmi.moduleInstanceID = @moduleInstanceID 

	if @isDebug = 1 
				print 'Insert ModuleInstance ' +	convert(varchar(50),@ModuleInstanceID)	

	insert into dbo.moduleInstance(
		moduleInstanceID,
		ZoneInstanceID,
		priority,
		moduleID,
		objectID,
		CreateUserID,
		CreateDate,
		UpdateUserID,
		UpdateDate)
	select 
		moduleInstanceID,
		ZoneInstanceID,
		priority,
		moduleID,
		objectID,
		@UpdateUserID,
		getdate(),
		@UpdateUserID,
		getdate()
	from dbo.PRODModuleInstance
	where moduleInstanceID =  @moduleInstanceID 
		and moduleInstanceID not in (select moduleInstanceID from dbo.ModuleInstance)


	if @isDebug = 1 
				print 'Update ModuleInstanceProperty ' +	convert(varchar(50),@ModuleInstanceID)
	update mip
	set mip.moduleInstanceID =pmip.moduleInstanceID ,
		mip.PropertyValue = pmip.PropertyValue,
		mip.propertyTemplateID = pmip.propertyTemplateID ,
		mip.UpdateUserID = @updateUserID,
		mip.UpdateDate = getdate() 
		from dbo.PRODModuleInstanceProperty pmip
			inner join dbo.ModuleInstanceProperty mip on pmip.InstancePropertyID = mip.InstancePropertyID
		where  pmip.ModuleInstanceID = @ModuleInstanceID 

	if @isDebug = 1 
				print 'Insert ModuleInstanceProperty ' +	convert(varchar(50),@ModuleInstanceID)
	insert into dbo.ModuleInstanceProperty(
		ModuleInstanceID,
		InstancePropertyID,
		propertyTemplateID,
		PropertyValue,
		CreateUserID,
		CreateDate,
		UpdateUserID,
		UpdateDate)
	select 
		ModuleInstanceID,
		InstancePropertyID,
		propertyTemplateID,
		PropertyValue,
		@UpdateUserID,
		getdate(),
		@UpdateUserID,
		getdate()
	from dbo.PRODModuleInstanceProperty
	where ModuleInstanceID =  @ModuleInstanceID 
		and InstancePropertyID not in (select InstancePropertyID from dbo.ModuleInstanceProperty)
end try

begin catch
	print error_message()
	 
		
	return 11811
end catch


End

GO
GRANT EXECUTE ON [dbo].[Core_moduleInstance_ReversePush] TO [websiteuser_role]
GO
