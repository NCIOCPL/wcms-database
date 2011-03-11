IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SetGatekeeperControlValue]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_SetGatekeeperControlValue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].usp_SetGatekeeperControlValue
	@SettingName	varchar(50),
	@SettingValue	varchar(50),
	@Status_Code int OUTPUT,
	@Status_Text varchar(255) OUTPUT
AS
BEGIN
	BEGIN TRY
	set nocount ON

		SET @Status_Code = 0
		SET @Status_Text = 'OK'

		DECLARE @Setting_Exists int
		Set @Setting_Exists = (select count(*) from dbo.ControlSettings where CSName = @SettingName)

		IF( @Setting_Exists > 0)
		BEGIN
			update dbo.ControlSettings
			set CSValue = @SettingValue
			where CSName = @SettingName
		END
		ELSE
		BEGIN
			insert into dbo.ControlSettings(CSName, CSValue)
			values( @SettingName, @SettingValue)
		END

		RETURN 0  --Succesful return 0
	END TRY

	BEGIN CATCH
		SET @Status_Code = -1000	-- Very big error
		SET @Status_Text = 'Exception thrown in usp_SetGatekeeperControlValue ' + ERROR_MESSAGE()
		RETURN 100101  --Error code
	END CATCH 
END


GO
GRANT EXECUTE ON [dbo].[usp_SetGatekeeperControlValue] TO [gatekeeper_role]
GO
