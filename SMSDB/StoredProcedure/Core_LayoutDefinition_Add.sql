IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_LayoutDefinition_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_LayoutDefinition_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].Core_LayoutDefinition_Add
	@NodeID uniqueidentifier
	,@LayoutTemplateID uniqueidentifier
	,@ContentAreaTemplateID uniqueidentifier
    ,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		Declare @rtnVal int

		INSERT INTO [dbo].[LayoutDefinition]
           ([NodeID]
           ,[LayoutTemplateID]
           ,[ContentAreaTemplateID]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate])
		  VALUES
			(
				@NodeID, 
				@LayoutTemplateID,
				@ContentAreaTemplateID,
				@CreateUserID,
				getdate(),
				@CreateUserID,
				getdate()
			)
	
		-- Create Zone instance for layout
		/*
		DECLARE	@Zone TABLE (
			RowNumber int identity( 1,1),
			TemplateZoneID uniqueidentifier
		);

		--Get all From LayoutTemplateZoneMap
		INSERT INTO @Zone
			(
				--RowNumber, 
				TemplateZoneID
			)
		SELECT	
			--Row_Number() over (order by TemplateZoneID) as RowNumber,
			TemplateZoneID
		FROM	dbo.LayoutTemplateZoneMap Where LayoutTemplateID = @LayoutTemplateID
		
		--Get all From dbo.ContentAreaTemplateZoneMap
		INSERT INTO @Zone
			(
				--RowNumber, 
				TemplateZoneID
			)
		SELECT	
			--Row_Number() over (order by TemplateZoneID) as RowNumber,
			TemplateZoneID
		FROM	dbo.ContentAreaTemplateZoneMap Where ContentAreaTemplateID = @ContentAreaTemplateID

		select * from @Zone

		DECLARE @LoopTemplateZoneID uniqueidentifier,
			@LoopCounter int

		set @LoopCounter = 1

		Select @LoopTemplateZoneID = TemplateZoneID
		FROM @Zone 
		WHERE RowNumber = @LoopCounter

		--Copy the data over
		While @@rowcount <> 0
		BEGIN
			print convert(varchar(36),@LoopTemplateZoneID )

			exec @rtnVal = Core_ZoneInstance_Add
				@NodeID = @NodeID
				,@CanInherit  = 0 --TODO: change to the value
				,@TemplateZoneID =@LoopTemplateZoneID
				,@CreateUserID = @CreateUserID

			IF @rtnVal <> 0
				RETURN @rtnVal
	
			SET @LoopCounter = @LoopCounter + 1

			Select @LoopTemplateZoneID = TemplateZoneID
			FROM @Zone 
			WHERE RowNumber = @LoopCounter
		END
		-- End Loop
		*/
		return 0

	END TRY

	BEGIN CATCH
		RETURN 12003
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_LayoutDefinition_Add] TO [websiteuser_role]
GO
