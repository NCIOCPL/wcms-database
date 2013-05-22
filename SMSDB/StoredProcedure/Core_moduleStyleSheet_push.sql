IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_moduleStyleSheet_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_moduleStyleSheet_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_moduleStyleSheet_push
@StyleSheetID uniqueidentifier,
@updateUserID varchar(50),
@isDebug bit = 0
AS
Begin
	
	
			begin try
				if exists (select 1 from dbo.PRODModuleStyleSheet where  StyleSheetID = @StyleSheetID)
				Begin
						if @isDebug = 1 
								print 'Update PRODModuleStyleSheet ' +	convert(varchar(50), @StyleSheetID)
						update pms
						set pms.MainclassName = ms.MainclassName,
							pms.CSS = ms.CSS, 
							pms.UpdateUserID = @updateUserID,
							pms.UpdateDate = getdate() 
							from dbo.PRODModuleStyleSheet pms 
								inner join dbo.ModuleStyleSheet ms on pms.StyleSheetID = ms.StyleSheetID
							where  pms.StyleSheetID = @StyleSheetID 
				end
				else
					begin
							if @isDebug = 1 
								print 'Insert PRODModuleStyleSheet ' +	convert(varchar(50), @StyleSheetID)
							insert into dbo.PRODModuleStyleSheet (
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
							from dbo.ModuleStyleSheet 
							where StyleSheetID =  @StyleSheetID 
								
					end
			end try
			begin catch
				print error_message()
				return 10110
			end catch




End

GO
GRANT EXECUTE ON [dbo].[Core_moduleStyleSheet_push] TO [websiteuser_role]
GO
