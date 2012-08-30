IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_moduleStyleSheet_Pushdelete]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_moduleStyleSheet_Pushdelete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_moduleStyleSheet_Pushdelete
@StyleSheetID uniqueidentifier,
@isDebug bit = 0
AS
Begin
begin try
--declare @StyleSheetID uniqueidentifier,@updateUserID varchar(50)
	if @isDebug = 1 
			print 'Delete from dbo.PRODModuleStyleSheet ' +	convert(varchar(50), @StyleSheetID)
	delete from dbo.PRODmoduleStylesheet
		where styleSheetid = @styleSheetid

end try
		
		
begin catch
	print error_message()
	 
		
	return 10110
end catch



End

GO
GRANT EXECUTE ON [dbo].[Core_moduleStyleSheet_Pushdelete] TO [websiteuser_role]
GO
