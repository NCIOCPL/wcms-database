IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyURL_Add]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyURL_Add]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PrettyURL_Add
	@PrettyURL varchar(512)
	,@NodeID uniqueidentifier = null
	,@RealURL varchar(512)  = null
	,@IsPrimary bit
	,@CreateUserID varchar(50)
AS
BEGIN
	BEGIN TRY
		if (dbo.Core_Function_PrettyURLExists(null, @PrettyURL) =1)
			return 10800

		print 'p1'
		if (@NodeID = null)
		BEGIN
				INSERT INTO PrettyURL
				(
					PrettyUrlID, 
					RealURL, 
					PrettyURL, 
					IsPrimary,	
					CreateUserID,
					UpdateUserID
				)
				VALUES
				(
					newid(),
					@RealURL,
					@PrettyURL,
					@IsPrimary,
					@CreateUserID,
					@CreateUserID
				)
		END
		ELSE		
		BEGIN
			
		print 'p2'
			if ( @RealURL is null or len(@RealURL) =0 )
			BEGIN
				Select @RealURL = dbo.Core_Function_GetRealURL(@NodeID)
			END

		print 'p3'
			if (@IsPrimary=1)
			BEGIN
				Update PrettyURL
				Set IsPrimary = 0 
				WHere NodeID =@NodeID
			END

		print 'p4'
			INSERT INTO [dbo].[PrettyUrl]
			   ([PrettyUrlID]
			   ,[NodeID]
			   ,[PrettyURL]
			   ,[RealURL]
			   ,[IsPrimary]
			   ,[CreateUserID]
			   ,[CreateDate]
			   ,[UpdateUserID]
			   ,[UpdateDate])
			Values
			(newid(), @NodeID, @PrettyURL, @RealURL, @IsPrimary, @CreateUserID, getdate(), @CreateUserID, getdate())
			

--		if (@NodeID  is not null)
--		BEGIN
--			Declare @rtnValue int
--
--
--			exec @rtnValue = dbo.Core_Node_SetStatus @NodeID
--			if (@rtnValue >0)
--				return @rtnValue
--		END

		return 0
		END
	END TRY

	BEGIN CATCH
		Print Error_Message()
		RETURN 10803
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyURL_Add] TO [websiteuser_role]
GO
