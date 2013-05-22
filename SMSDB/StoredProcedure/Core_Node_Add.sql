IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_Node_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_Node_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_Node_Add
	@layoutTemplateID uniqueidentifier = null
	,@contentAreaTemplateID uniqueidentifier = null
	,@Title		varchar(255)
    ,@ShortTitle varchar(50)
    ,@Description varchar(1500)
	,@ParentNodeID uniqueidentifier = null
	,@PrettyURL varchar(512)
	,@showInNavigation	bit
	,@showInBreadCrumbs	bit
	,@CreateUserID varchar(50)
	,@NodeID uniqueidentifier output
	,@DisplayPostedDate datetime = '1/1/1980',
			@DisplayUpdateDate datetime = '1/1/1980',
			@DisplayReviewDate datetime = '1/1/1980',
			@DisplayExpirationDate datetime = '1/1/2100',
			@DisplayDateMode tinyint = 1
AS
BEGIN
	Declare @rtnValue int
		,@ParentlayoutTemplateID uniqueidentifier 
		,@ParentcontentAreaTemplateID uniqueidentifier 
		,@Priority int
		,@ZoneInstanceID uniqueidentifier 
		,@TemplateZoneID uniqueidentifier

	--We can only have 1 root node.  So if the parent node passed in is null
	--and there is alreay a node where the parent node is null, then error out.
	--obviously this will cause issue if we ever want to replace the root with a
	--new root.  I would suggest that we simple move all of the children or write a
	--new function.
	IF (@ParentNodeID is null)
		IF (EXISTS(SELECT NodeID FROM Node WHERE ParentNodeID is null))
			RETURN 11120

	BEGIN TRY
		SELECT @NodeID = NewID()
		SELECT @Priority = dbo.Core_Function_NodeGetPriority(@ParentNodeID, @NodeID)
		
		print str(@Priority)

		INSERT INTO [dbo].[Node]
           ([NodeID]
           ,[Title]
           ,[ShortTitle]
           ,[Description]
           ,[ParentNodeID]
           ,[ShowInNavigation]
           ,[ShowInBreadCrumbs]
           ,[Priority]
           ,[CreateUserID]
           ,[CreateDate]
           ,[UpdateUserID]
           ,[UpdateDate],
			DisplayPostedDate ,
			DisplayUpdateDate ,
			DisplayReviewDate ,
			DisplayExpirationDate,
			DisplayDateMode
			)
		 VALUES
			(@NodeID, @Title, @ShortTitle, @Description,@ParentNodeID, @showInNavigation, @showInBreadCrumbs, @Priority,
			@CreateUserID, getdate(),@CreateUserID,getdate(), 
			@DisplayPostedDate ,
			@DisplayUpdateDate ,
			@DisplayReviewDate ,
			@DisplayExpirationDate,
			@DisplayDateMode
			)


		-- Insert layout Definition
		if (@ParentNodeID is not null)
		BEGIN
			select @ParentlayoutTemplateID = layoutTemplateID, @ParentcontentAreaTemplateID = contentAreaTemplateID
			from dbo.LayoutDefinition where nodeID = @ParentNodeID
		
			if (@layoutTemplateID  is null)
				select @layoutTemplateID = @ParentlayoutTemplateID;

			if (@contentAreaTemplateID  is null)
				select @contentAreaTemplateID = @ParentcontentAreaTemplateID;
		END

		exec @rtnValue = [dbo].Core_LayoutDefinition_Add
			@NodeID = @NodeID
			,@LayoutTemplateID =@layoutTemplateID
			,@ContentAreaTemplateID = @contentAreaTemplateID
			,@CreateUserID = @CreateUserID
		
		if (@rtnValue <> 0)
			return @rtnValue

		-- Get MainTargetZone and add zone instance	
		if (exists (select 1 from  dbo.TemplateZone Z, dbo.ContentAreaTemplateZoneMap M
where  M.contentAreaTemplateID = @contentAreaTemplateID and M.TemplateZoneID = Z.TemplateZoneID
and Z.ZoneName='MainTargetZone'))
		BEGIN
			select @TemplateZoneID = M.TemplateZoneID from dbo.TemplateZone Z, dbo.ContentAreaTemplateZoneMap M
where  M.contentAreaTemplateID = @contentAreaTemplateID and M.TemplateZoneID = Z.TemplateZoneID
and Z.ZoneName='MainTargetZone'

			exec @rtnValue = Core_ZoneInstance_Add
				@NodeID  = @NodeID
				,@CanInherit = 0
				,@TemplateZoneID =@TemplateZoneID
				,@UpdateUserID = @CreateUserID
				,@ZoneInstanceID  = @ZoneInstanceID output
			
			if (@rtnValue <> 0)
				return @rtnValue
		END

		--Insert primary Pretty URL
		exec @rtnValue = Core_PrettyURL_Add
			@PrettyURL = @PrettyURL,
			@NodeID = @NodeID,
			@RealURL = '',
			@IsPrimary = 1,
			@CreateUserID= @CreateUserID
		
		if (@rtnValue <> 0)
			return @rtnValue

		--rebuld permission
		exec @rtnValue = Core_ObjectPermission_RebuildNodeRoleBinaryForNode @NodeID	
		if (@rtnValue <> 0)
			return @rtnValue

		return 0

	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 11103
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_Node_Add] TO [websiteuser_role]
GO
