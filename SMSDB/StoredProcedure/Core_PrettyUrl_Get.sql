IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyUrl_Get]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyUrl_Get]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PrettyUrl_Get
	@PrettyUrlID uniqueidentifier
AS
BEGIN
	BEGIN TRY

		SELECT [PrettyUrlID]
			  ,[NodeID]
			  ,[PrettyURL]
			  ,[RealURL]
			  ,[IsPrimary]
			,(
						SELECT PropertyValue 
						FROM NodeProperty np 
						JOIN PropertyTemplate pt 
						ON np.PropertyTemplateID = pt.PropertyTemplateID
						AND pt.PropertyName = 'RedirectUrl'
					WHERE NodeID = pu.NodeID
					  ) as RedirectUrl
			  ,[CreateUserID]
			  ,[CreateDate]
			  ,[UpdateUserID]
			  ,[UpdateDate]
		  FROM [dbo].[PrettyUrl] pu
		  Where [PrettyUrlID] = @PrettyUrlID
		
	END TRY

	BEGIN CATCH
		RETURN 10801
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyUrl_Get] TO [websiteuser_role]
GO
