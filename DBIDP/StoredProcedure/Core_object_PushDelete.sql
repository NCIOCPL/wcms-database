IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_object_PushDelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_object_PushDelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

----------
--delete List, htmlcontent, document and object
---------

CREATE  PROCEDURE dbo.Core_object_PushDelete
@ObjectID uniqueidentifier,
@isDebug bit= 0
AS
Begin
--declare @ObjectID uniqueidentifier,@updateUserID varchar(50)
	
	declare @objectTypeName varchar(50), @rtnValue int
	
begin try
		
	select @objectTypeName = ot.name 
		from dbo.PRODObject o 
				inner join  DBO.objecttype ot on o.objectTypeid= ot.objecttypeID	
		where objectid = @objectId

	if @isDebug = 1 
		print 'in  Core_object_PushDelete, objectTypeName ' +	convert(varchar(50), @objectTypeName)

	if @objecttypeName = 'List'
		begin
		if @isDebug = 1 
			print 'list_list_Pushdelete in core_object_pushDelete ' +	convert(varchar(50), @objectID)
		Exec @rtnValue =  dbo.list_list_Pushdelete @objectID, @isdebug
		if @rtnValue <> 0
			return @rtnValue		
		end
	
	if @objecttypeName = 'htmlcontent'
		begin
		if @isDebug = 1 
			print 'Htmlcontent_Pushdelete ' +	convert(varchar(50), @objectID)
		Exec @rtnValue =  dbo.HtmlContent_Pushdelete @objectID, @isdebug
		if @rtnValue <> 0
			return @rtnValue		
		end


   if @isDebug = 1 
		print 'Delete from dbo.PRODObject ' +	convert(varchar(50), @objectID)
	delete from dbo.PRODobject where objectid = @objectid		

end try

begin catch
	print error_message()
	 
		
	return 11910
end catch

End

GO
GRANT EXECUTE ON [dbo].[Core_object_PushDelete] TO [websiteuser_role]
GO
