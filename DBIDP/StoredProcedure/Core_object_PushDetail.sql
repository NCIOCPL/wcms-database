IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_object_PushDetail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_object_PushDetail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_object_PushDetail
@ObjectID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
--declare @ObjectID uniqueidentifier,@updateUserID varchar(50)
	
	declare @objectTypeName varchar(50), @rtnValue int
	select @rtnvalue = 0
	

begin try
	
					if exists (select 1 from dbo.PRODObject where objectid = @objectID)	
						begin
								if @isDebug = 1 
										print 'Update PRODObject ' +	convert(varchar(50),@ObjectID)
								update po
									set po.objectTypeID =o.objectTypeID ,
										po.OwnerID = o.OwnerID,
										po.title = o.title ,
										po.isShared = o.isShared ,
										po.isVirtual = o.isVirtual 
									from dbo.PRODobject po	
											inner join  DBO.object o on po.ObjectID = o.ObjectID
										where  po.ObjectID = @ObjectID 
						end
					else
						begin
							if @isDebug = 1 
									print 'Insert PRODObject ' +	convert(varchar(50),@ObjectID)			
							insert into dbo.PRODobject(
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
								from DBO.object
									where ObjectID =  @ObjectID 
						end
						
					select @objectTypeName = ot.name 
						from dbo.PRODObject o 
								inner join  DBO.objecttype ot on o.objectTypeid= ot.objecttypeID	
							where objectID = @objectID

					if @isDebug = 1 
						print 'in  Core_object_PushDetail, objectTypeName ' +	convert(varchar(50), @objectTypeName)

					if @objecttypeName = 'List'
						begin
							if @isDebug = 1 
								print 'in  Core_object_PushDetail, list_list_Push ' +	convert(varchar(50), @objectID)
								Exec @rtnValue = dbo.List_list_push @objectID, @updateUserID, @isDebug
							if @rtnValue <> 0
								return @rtnValue
						end
					
					if @objecttypeName = 'htmlcontent'
						begin
							if @isDebug = 1 
								print 'HtmlContent_Push ' +	convert(varchar(50), @objectID)
							Exec @rtnValue = dbo.HtmlContent_push @objectID, @updateUserID, @isDebug
							if @rtnValue <> 0
								return @rtnValue
						end

				
					if @isDebug = 1 
						print 'Update Object set isDirty to 0 ' +	convert(varchar(50), @objectID)
					update DBO.object set isDirty  =0 where objectID = @objectID
					
	
end try

begin catch
	print error_message()
	 
		
	return 11910
end catch

End

GO
GRANT EXECUTE ON [dbo].[Core_object_PushDetail] TO [websiteuser_role]
GO
