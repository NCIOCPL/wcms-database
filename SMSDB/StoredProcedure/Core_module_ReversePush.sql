IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_module_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_module_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_module_ReversePush
@ModuleID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin

--declare @moduleid uniqueidentifier,@updateUserID varchar(50)
	declare @CSSID uniqueidentifier, @rtnValue int
			begin try
					select @CSSID = CSSID from dbo.PRODModule where moduleid = @moduleID

					exec @rtnValue = dbo.core_moduleStylesheet_ReversePush @CSSID, @updateUserID,  @isDebug
					if @rtnValue <> 0 
								return @rtnValue
						
						if exists (select 1 from dbo.Module where moduleid = @moduleID)
							begin  		 	
									if @isDebug = 1 
											print 'Update Module ' +	convert(varchar(50),@ModuleID)
									update m
									set m.moduleName = pm.moduleName,
										m.genericModuleID =pm.genericModuleID ,
										m.cssID = pm.cssID, 
										m.UpdateUserID = @updateUserID,
										m.UpdateDate = getdate() 
										from dbo.Module m 
											inner join dbo.PRODModule pm on pm.ModuleID = m.ModuleID
										where  m.moduleID = @moduleID 
							end
						else
							begin
									if @isDebug = 1 
											print 'Insert Module ' +	convert(varchar(50),@ModuleID)

									insert into dbo.Module (
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
									from dbo.PRODModule 
									where moduleID =  @moduleID 
							end
				end try
				begin catch
					print error_message()
					return 10311
				end catch
				



End

GO
GRANT EXECUTE ON [dbo].[Core_module_ReversePush] TO [websiteuser_role]
GO
