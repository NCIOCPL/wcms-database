IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_moduleStyleSheet_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_moduleStyleSheet_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_moduleStyleSheet_ReversePush
@StyleSheetID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
	
			begin try
				if exists (select 1 from dbo.ModuleStyleSheet where  StyleSheetID = @StyleSheetID)
				Begin
						if @isDebug = 1 
								print 'Update ModuleStyleSheet ' +	convert(varchar(50), @StyleSheetID)
						update ms
						set ms.MainclassName = pms.MainclassName,
							ms.CSS = pms.CSS, 
							ms.UpdateUserID = @updateUserID,
							ms.UpdateDate = getdate() 
							from dbo.ModuleStyleSheet ms 
								inner join dbo.PRODModuleStyleSheet pms on pms.StyleSheetID = ms.StyleSheetID
							where  ms.StyleSheetID = @StyleSheetID 
				end
				else
					begin
							if @isDebug = 1 
								print 'Insert ModuleStyleSheet ' +	convert(varchar(50), @StyleSheetID)
							insert into dbo.ModuleStyleSheet (
								StyleSheetID,
								MainclassName,
								CSS,
								CreateUserID,
								CreateDate,
								UpdateUserID,
								UpdateDate)
							select 
								StyleSheetID,
								MainclassName,
								CSS,
								@UpdateUserID,
								getdate(),
								@UpdateUserID,
								getdate()
							from dbo.PRODModuleStyleSheet 
							where StyleSheetID =  @StyleSheetID 
								
					end
			end try
			begin catch
				print error_message()
				return 10111
			end catch
	

End

GO
GRANT EXECUTE ON [dbo].[Core_moduleStyleSheet_ReversePush] TO [websiteuser_role]
GO
