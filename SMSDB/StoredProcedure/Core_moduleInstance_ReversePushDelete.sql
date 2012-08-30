IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_moduleInstance_ReversePushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_moduleInstance_ReversePushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--------
--delete a ModuleInstance's 
--object, 
--all moduleInstanceProperty, 
--moduleInstance
-------

CREATE  PROCEDURE dbo.Core_moduleInstance_ReversePushDelete
@moduleInstanceID uniqueidentifier,
@nodeID uniqueIdentifier,
@isDebug bit = 0
AS
Begin
--declare @moduleInstanceID uniqueidentifier,@updateUserID varchar(50)

begin try


declare @rtnValue int 

-- delete object
--use  dbo.Core_object_delete to delete List, htmlcontent, document and object
declare @objectID uniqueidentifier

if @isDebug = 1 
			print 'In dbo.Core_ModuleInstance_ReversePushdelete ' +	convert(varchar(50),@NodeID)

---Get @ObjectID
select @objectID = mi.objectId from dbo.ModuleInstance mi inner join dbo.Object o on o.objectid= mi.objectid
		where moduleInstanceID = @moduleInstanceID  and ownerID = @nodeID and mi.Objectid not in (select objectID from DBO.PRODobject)
--Delete ModuleInstanceProperty

if @isDebug = 1 
		print 'Delete from dbo.ModuleInstanceProperty ' +	convert(varchar(50),@ModuleInstanceID)

delete from dbo.ModuleInstanceProperty where InstancePropertyID in
	(select InstancePropertyid  from dbo.ModuleInstance mi 
		inner join dbo.ModuleInstanceProperty mip on mip.moduleinstanceID = mi.moduleInstanceID
		 where mi.ModuleInstanceid = @ModuleInstanceID 
		except
	select InstancePropertyid  from  dbo.PRODModuleInstance Pmi 
		inner join dbo.PRODModuleInstanceProperty Pmip on Pmip.moduleinstanceID = pmi.moduleInstanceID
		 where pmi.ModuleInstanceid = @ModuleInstanceID 
	)


--delete ModuleInstance
if @isDebug = 1 
		print 'Delete from dbo.PRODModuleInstance ' +	convert(varchar(50),@ModuleInstanceID)
delete from dbo.ModuleInstance where moduleInstanceID = @moduleInstanceID



if @objectID is not null
	begin
		if @isDebug = 1 
			print 'dbo.Core_object_delete ' +	convert(varchar(50),@ObjectID)
		exec @rtnValue =dbo.Core_object_ReversePushDelete @objectID, @isDebug
		if @rtnValue <> 0
			return @rtnValue
	end


end try

begin catch
	print error_message()
	 
		
	return 11811
end catch


End

GO
GRANT EXECUTE ON [dbo].[Core_moduleInstance_ReversePushDelete] TO [websiteuser_role]
GO
