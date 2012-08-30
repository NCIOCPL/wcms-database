IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_moduleInstance_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_moduleInstance_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE dbo.Core_moduleInstance_push
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
			print 'In dbo.Core_moduleInstance_push ' +	convert(varchar(50),@ModuleInstanceID)
	declare @moduleID uniqueidentifier, @zoneInstanceID uniqueIdentifier, @objectID uniqueIdentifier, @rtnValue int

	select	@moduleID = moduleID, 
			@ZoneInstanceID = ZoneInstanceID, 
			@objectID= objectid 
		from dbo.ModuleInstance where moduleInstanceID = @moduleInstanceID
	
	declare @isShared bit , @ownerid uniqueidentifier

	select @isShared = isShared, @ownerid = ownerid
		from DBO.object where objectid= @objectid

	if @isShared = 1 and @ownerid = @nodeid
		if not exists (select 1 from dbo.PRODnode where nodeid = @nodeid)
			begin 
				print 'shared object''s nodeid = ownerid, but owner not on Live, do not push the moduleinstance'
				return 0
			end



--	if @isDebug = 1 
--			print 'Core_module_push ' +	convert(varchar(50),@ModuleID)
--	exec @rtnValue = dbo.Core_module_push @moduleID,@updateUserID,@isDebug
--	if @rtnValue <> 0
--			return @rtnValue
	
--	if @isDebug = 1 
--			print 'Core_ZoneInstance_push ' +	convert(varchar(50),@ZoneInstanceID)
--	exec @rtnValue = dbo.Core_ZoneInstance_push @ZoneInstanceID,@updateUserID, @isdebug
--	if @rtnValue <> 0
--			return @rtnValue
	
-- Only push 
	if exists (select 1 from DBO.object o 
					inner join dbo.Moduleinstance mi on o.objectid = mi.objectid 
					where o.objectid = @objectID and isDirty = 1 and ownerID = @nodeID
				)
		begin
			if @isDebug = 1 
				print 'Core_Object_push ' +	convert(varchar(50),@ObjectID)
			exec @rtnValue = dbo.Core_Object_push @ObjectID,@nodeid, @updateUserID, @isDebug
			if @rtnValue <> 0
				return @rtnValue
		end
				

	if @isDebug = 1 
			print 'Update PRODModuleInstance ' +	convert(varchar(50),@ModuleInstanceID)

	update pmi
		set pmi.ZoneInstanceID =mi.ZoneInstanceID ,
			pmi.moduleID = mi.moduleID,
			pmi.priority = mi.priority ,
			pmi.objectID = mi.ObjectID,
			pmi.UpdateUserID = @updateUserID,
			pmi.UpdateDate = getdate() 
			from dbo.PRODmoduleInstance pmi
				inner join dbo.ModuleInstance mi on pmi.moduleInstanceID = mi.moduleInstanceID
			where  pmi.moduleInstanceID = @moduleInstanceID 

	if @isDebug = 1 
				print 'Insert PRODModuleInstance ' +	convert(varchar(50),@ModuleInstanceID)	

	insert into dbo.PRODmoduleInstance(
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
	from dbo.ModuleInstance
	where moduleInstanceID =  @moduleInstanceID 
		and moduleInstanceID not in (select moduleInstanceID from dbo.PRODModuleInstance)

if @isDebug = 1 
				print 'delete PRODModuleInstanceProperty ' +	convert(varchar(50),@ModuleInstanceID)	


delete dbo.PRODModuleInstanceProperty
where ModuleInstanceID =  @ModuleInstanceID 
		    and InstancePropertyID not  in (select InstancePropertyID from dbo.ModuleInstanceProperty
		    where ModuleInstanceID =  @ModuleInstanceID)




	if @isDebug = 1 
				print 'Update PRODModuleInstanceProperty ' +	convert(varchar(50),@ModuleInstanceID)
	update pmip
	set pmip.moduleInstanceID =mip.moduleInstanceID ,
		pmip.PropertyValue = mip.PropertyValue,
		pmip.propertyTemplateID = mip.propertyTemplateID ,
		pmip.UpdateUserID = @updateUserID,
		pmip.UpdateDate = getdate() 
		from dbo.PRODModuleInstanceProperty pmip
			inner join dbo.ModuleInstanceProperty mip on pmip.InstancePropertyID = mip.InstancePropertyID
		where  pmip.ModuleInstanceID = @ModuleInstanceID 

	if @isDebug = 1 
				print 'Insert PRODModuleInstanceProperty ' +	convert(varchar(50),@ModuleInstanceID)
	insert into dbo.PRODModuleInstanceProperty(
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
	from dbo.ModuleInstanceProperty
	where ModuleInstanceID =  @ModuleInstanceID 
		and InstancePropertyID not in (select InstancePropertyID from dbo.PRODModuleInstanceProperty)
end try

begin catch
	print error_message()
	 
		
	return 11810
end catch


End

GO
GRANT EXECUTE ON [dbo].[Core_moduleInstance_push] TO [websiteuser_role]
GO
