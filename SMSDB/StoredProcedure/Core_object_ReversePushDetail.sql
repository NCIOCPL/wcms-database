IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_object_ReversePushDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_object_ReversePushDetail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_object_ReversePushDetail
@ObjectID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
--declare @ObjectID uniqueidentifier,@updateUserID varchar(50)
	
	declare @objectTypeName varchar(50), @rtnValue int
	select @rtnvalue = 0
	

begin try
	
					if exists (select 1 from dbo.Object where objectid = @objectID)	
						begin
								if @isDebug = 1 
										print 'Update Object ' +	convert(varchar(50),@ObjectID)
								update o
									set o.objectTypeID =po.objectTypeID ,
										o.OwnerID = po.OwnerID,
										o.title = po.title ,
										o.isShared = po.isShared ,
										o.isVirtual = po.isVirtual 
									from dbo.PRODobject po	
											inner join  DBO.object o on po.ObjectID = o.ObjectID
										where  po.ObjectID = @ObjectID 
						end
					else
						begin
							if @isDebug = 1 
									print 'Insert Object ' +	convert(varchar(50),@ObjectID)			
							insert into dbo.object(
									ObjectID,
									objectTypeID,
									title,
									OwnerID,
									isShared ,
									isVirtual
									)
								select 
									ObjectID,
									objectTypeID,
									title,
									OwnerID,
									isShared ,
									isVirtual
								from DBO.PRODobject
									where ObjectID =  @ObjectID 
						end
						
					select @objectTypeName = ot.name 
						from dbo.Object o 
								inner join  DBO.objecttype ot on o.objectTypeid= ot.objecttypeID	
							where objectID = @objectID

					if @isDebug = 1 
						print 'in  Core_object_ReversePushDetail, objectTypeName ' +	convert(varchar(50), @objectTypeName)

					if @objecttypeName = 'List'
						begin
							if @isDebug = 1 
								print 'in  Core_object_ReversePushDetail, list_list_ReversePush ' +	convert(varchar(50), @objectID)
								Exec @rtnValue = dbo.List_list_ReversePush @objectID, @updateUserID, @isDebug
							if @rtnValue <> 0
								return @rtnValue
						end
					
					if @objecttypeName = 'htmlcontent'
						begin
							if @isDebug = 1 
								print 'HtmlContent_ReversePush ' +	convert(varchar(50), @objectID)
							Exec @rtnValue = dbo.HtmlContent_ReversePush @objectID, @updateUserID, @isDebug
							if @rtnValue <> 0
								return @rtnValue
						end

				
					if @isDebug = 1 
						print 'Update PRODObject set isDirty to 0 ' +	convert(varchar(50), @objectID)
					update DBO.PRODobject set isDirty  =0 where objectID = @objectID
					
	
end try

begin catch
	print error_message()
	 
		
	return 11911
end catch

End

GO
GRANT EXECUTE ON [dbo].[Core_object_ReversePushDetail] TO [websiteuser_role]
GO
