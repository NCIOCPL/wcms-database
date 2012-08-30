IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_module_ReversePushdelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_module_ReversePushdelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_module_ReversePushdelete
@ModuleID uniqueidentifier,
@isDebug bit = 0
AS
Begin
begin try
--declare @moduleid uniqueidentifier,@updateUserID varchar(50)

if @isDebug = 1 
		print 'Delete from dbo.Module ' +	convert(varchar(50), @ModuleID)
delete from dbo.module where moduleid = @moduleID
	
end try
		
		
begin catch
	print error_message()
	 
		
	return 10311
end catch



End

GO
GRANT EXECUTE ON [dbo].[Core_module_ReversePushdelete] TO [websiteuser_role]
GO
