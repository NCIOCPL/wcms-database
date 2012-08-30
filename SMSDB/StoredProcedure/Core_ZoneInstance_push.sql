IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ZoneInstance_push]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ZoneInstance_push]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_ZoneInstance_push
@ZoneInstanceID uniqueidentifier,
@updateUserID varchar(50),
@isdebug bit = 0
AS
Begin

--declare @ZoneInstanceID uniqueidentifier,@updateUserID varchar(50)

begin try

	if exists (select 1 from dbo.PRODZoneinstance where ZoneInstanceID = @ZoneInstanceID )
		begin
				if @isDebug = 1 
						print 'Update PRODZoneInstance ' +	convert(varchar(50),@ZoneInstanceID)
				update pzi
					set pzi.CanInherit = zi.CanInherit,
						pzi.TemplateZoneID = zi.TemplateZoneID,
						pzi.UpdateUserID = @updateUserID,
						pzi.UpdateDate = getdate() 
					from dbo.PRODZoneInstance pzi 
						inner join DBO.ZoneInstance zi on pzi.zoneInstanceID = zi.zoneInstanceID
					where  pzi.ZoneInstanceID = @ZoneInstanceID 
		end
	else
		begin
				if @isDebug = 1 
					print 'Insert PRODzoneinstance ' +	convert(varchar(50),@ZoneInstanceID)
				insert into dbo.PRODZoneInstance (
					NodeID,
					ZoneInstanceID,
					TemplateZoneID,
					CanInherit,
					CreateUserID,
					CreateDate,
					UpdateUserID,
					UpdateDate)
				select 
					NodeID,
					ZoneInstanceID,
					TemplateZoneID,
					CanInherit,
					@UpdateUserID,
					getdate(),
					@UpdateUserID,
					getdate()
				from DBO.ZoneInstance 
					where ZoneInstanceID =  @ZoneInstanceID 
		end
end try
		
		
begin catch
	print error_message()
	 
		
	return 11310
end catch

			
		
End

GO
GRANT EXECUTE ON [dbo].[Core_ZoneInstance_push] TO [websiteuser_role]
GO
