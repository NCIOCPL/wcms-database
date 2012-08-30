IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_module_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_module_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_module_push
@ModuleID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
begin try
--declare @moduleid uniqueidentifier,@updateUserID varchar(50)

	declare @CSSID uniqueidentifier, @rtnValue int
	select @CSSID = CSSID from dbo.Module where moduleid = @moduleID

--	exec @rtnValue = dbo.core_moduleStylesheet_push @CSSID, @updateUserID, @isDebug
--	if @rtnValue <> 0 
--				return @rtnValue
		

		if exists (select 1 from dbo.PRODModule where moduleid = @moduleID)
			begin  		 	
					if @isDebug = 1 
							print 'Update PRODModule ' +	convert(varchar(50),@ModuleID)
					update pm
					set pm.moduleName = m.moduleName,
						pm.genericModuleID =m.genericModuleID ,
						pm.cssID = m.cssID, 
						pm.UpdateUserID = @updateUserID,
						pm.UpdateDate = getdate() 
						from dbo.PRODModule pm 
							inner join dbo.Module m on pm.ModuleID = m.ModuleID
						where  pm.moduleID = @moduleID 
			end
		else
			begin
					if @isDebug = 1 
							print 'Insert PRODModule ' +	convert(varchar(50),@ModuleID)

					insert into dbo.PRODModule (
						moduleID,
						genericModuleID,
						moduleName,
						CSSID,
						CreateUserID,
						CreateDate,
						UpdateUserID,
						UpdateDate)
					select 
						moduleID,
						genericModuleID,
						moduleName,
						CSSID,
						@UpdateUserID,
						getdate(),
						@UpdateUserID,
						getdate()
					from dbo.Module 
					where moduleID =  @moduleID 
			end
end try
		
		
begin catch
	print error_message()
	 
		
	return 10310
end catch



End

GO
GRANT EXECUTE ON [dbo].[Core_module_push] TO [websiteuser_role]
GO
