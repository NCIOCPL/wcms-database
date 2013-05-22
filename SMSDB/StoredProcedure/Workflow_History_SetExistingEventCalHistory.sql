IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Workflow_History_SetExistingEventCalHistory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Workflow_History_SetExistingEventCalHistory]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Workflow_History_SetExistingEventCalHistory 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @ObjectID uniqueidentifier,
		@IsPublished bit, 
		@IsCancelled bit, 
		@IsDeleted bit,
		@OwnerID  uniqueidentifier


	Declare @Workflow table (
		RowID int
		, ObjectID uniqueidentifier
		, IsPublished bit
		, IsCancelled bit
		, IsDeleted bit
		, OwnerID  uniqueidentifier
	)
	
	BEGIN TRY

		insert into @Workflow(RowID, ObjectID, IsPublished, IsCancelled, IsDeleted, OwnerID)
		select Row_Number() over (order by Title) as RowID, EventID, 
			IsPublished, IsCancelled, IsDeleted, OwnerID
		from dbo.ECEvent
		order by Title

		-- Insert statements for procedure here
		Declare @rowNum int
		Set @rowNum = 1
		Select @ObjectID = ObjectID, @IsPublished = IsPublished, 
				@IsCancelled = IsCancelled, @IsDeleted = IsDeleted, @OwnerID= OwnerID
		From @Workflow
		Where rowID = @rowNum
		While @@Rowcount <> 0		
		begin
			-- Draft
			exec dbo.WorkFlow_ObjectState_Update
					@ObjectID = @ObjectID,
					@TransitionNAme ='Create',
					@State ='Draft',
					@IsPublished = 0,
					@Notes ='',
					@UpdateUserID =@OwnerID

			If (@IsPublished = 1 or @IsCancelled=1 or @IsDeleted =1)
			Begin
				-- Submit
				exec dbo.WorkFlow_ObjectState_Update
					@ObjectID = @ObjectID,
					@TransitionNAme ='Submit',
					@State ='Submitted',
					@IsPublished = 0,
					@Notes ='Submitted',
					@UpdateUserID =@OwnerID
				-- Live
				exec dbo.WorkFlow_ObjectState_Update
					@ObjectID = @ObjectID,
					@TransitionNAme ='Approve',
					@State ='Published',
					@IsPublished = 1,
					@Notes ='',
					@UpdateUserID =5188146770731156851

				exec EC_Event_PushToProduction  
					@ObjectID = @ObjectID,
					@modifyNCIUserID = 5188146770731156851

				If (@IsCancelled=1)
				Begin
					-- Submitted for Cancel
					exec dbo.WorkFlow_ObjectState_Update
						@ObjectID = @ObjectID,
						@TransitionNAme ='Cancel',
						@State ='Submitted for Cancel',
						@IsPublished = 1,
						@Notes ='',
						@UpdateUserID =@OwnerID
					
					-- Approve Cancel
					exec dbo.WorkFlow_ObjectState_Update
						@ObjectID = @ObjectID,
						@TransitionNAme ='Approve',
						@State ='Cancelled',
						@IsPublished = 1,
						@Notes ='',
						@UpdateUserID =5188146770731156851
				END

				If (@IsDeleted =1)
				Begin
					-- Submitted for Delete
					exec dbo.WorkFlow_ObjectState_Update
						@ObjectID = @ObjectID,
						@TransitionNAme ='Delete',
						@State ='Submitted for Deletion',
						@IsPublished = 1,
						@Notes ='',
						@UpdateUserID =@OwnerID
					
					-- Approve Delete
					exec dbo.WorkFlow_ObjectState_Update
						@ObjectID = @ObjectID,
						@TransitionNAme ='Approve',
						@State ='Deleted',
						@IsPublished = 1,
						@Notes ='',
						@UpdateUserID =5188146770731156851
				END
			End

			Print 'Complete ' + convert(varchar(36), @ObjectID)

			set @rowNum = @rowNum + 1
			Select @ObjectID = ObjectID, @IsPublished = IsPublished, 
				@IsCancelled = IsCancelled, @IsDeleted = IsDeleted, @OwnerID= OwnerID
			From @Workflow
			Where rowID = @rowNum

		end

	END TRY
	BEGIN CATCH 
		--Return Error Number
		Print Error_Message()
	END CATCH	  

END

GO
