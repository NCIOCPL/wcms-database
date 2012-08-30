IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_object_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_object_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_object_ReversePush
@ObjectID uniqueidentifier,
@nodeid uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
--declare @ObjectID uniqueidentifier,@updateUserID varchar(50)
	
	declare @objectTypeName varchar(50), @rtnValue int
	declare @isShared bit ,  @ownerID uniqueidentifier
	select @rtnvalue = 0
	

begin try
	select @isshared = isshared, @ownerid = ownerid from DBO.PRODobject where objectid = @objectID 
	if @isshared = 1  
		begin
			if @ownerid = @nodeid
					if @isDebug = 1 
						print 'shared object, Core_object_ReversePushDetail ' +	convert(varchar(50),@ObjectID)
					exec  @rtnvalue = dbo.Core_object_ReversePushDetail @objectid, @updateUserID, @isdebug
					if @rtnValue <> 0
						return @rtnValue
		end
	else 
		begin
			if @isDebug = 1 
				print 'Core_object_ReversePushDetail ' +	convert(varchar(50),@ObjectID)
			exec  @rtnvalue = dbo.Core_object_ReversePushDetail @objectid, @updateUserID, @isdebug
			if @rtnValue <> 0
				return @rtnValue
					
		end
end try

begin catch
	print error_message()
	 
		
	return 11911
end catch

End

GO
GRANT EXECUTE ON [dbo].[Core_object_ReversePush] TO [websiteuser_role]
GO
