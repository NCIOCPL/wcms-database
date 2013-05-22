IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_ZoneInstance_ReversePush]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_ZoneInstance_ReversePush]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE dbo.Core_ZoneInstance_ReversePush
@ZoneInstanceID uniqueidentifier,
@updateUserID varchar(50),
@isdebug bit = 0
AS
Begin

--declare @ZoneInstanceID uniqueidentifier,@updateUserID varchar(50)

begin try

	if exists (select 1 from dbo.Zoneinstance where ZoneInstanceID = @ZoneInstanceID )
		begin
				if @isDebug = 1 
						print 'Update ZoneInstance ' +	convert(varchar(50),@ZoneInstanceID)
				update zi
					set zi.CanInherit = pzi.CanInherit,
						zi.TemplateZoneID = pzi.TemplateZoneID,
						zi.UpdateUserID = @updateUserID,
						zi.UpdateDate = getdate() 
					from dbo.PRODZoneInstance pzi 
						inner join DBO.ZoneInstance zi on pzi.zoneInstanceID = zi.zoneInstanceID
					where  pzi.ZoneInstanceID = @ZoneInstanceID 
		end
	else
		begin
				if @isDebug = 1 
					print 'Insert zoneinstance ' +	convert(varchar(50),@ZoneInstanceID)
				insert into dbo.ZoneInstance (
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
				from DBO.PRODZoneInstance 
					where ZoneInstanceID =  @ZoneInstanceID 
		end
end try
		
		
begin catch
	print error_message()
	 
		
	return 11311
end catch

			
		
End

GO
GRANT EXECUTE ON [dbo].[Core_ZoneInstance_ReversePush] TO [websiteuser_role]
GO
