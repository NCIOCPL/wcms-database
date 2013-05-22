IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Core_PrettyURL_GetAll]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Core_PrettyURL_GetAll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].Core_PrettyURL_GetAll
@isLive bit = 0
AS
BEGIN
	BEGIN TRY
		
	if @isLive = 1
			SELECT [PrettyUrlID]
				  ,[NodeID]
				  ,[PrettyURL]
				  ,[RealURL]
				  ,[IsPrimary]
				  ,(
					SELECT PropertyValue 
					FROM PRODNodeProperty np 
					JOIN PropertyTemplate pt 
					ON np.PropertyTemplateID = pt.PropertyTemplateID
					AND pt.PropertyName = 'RedirectUrl'
					WHERE NodeID = pu.NodeID
				  ) as RedirectUrl
				  ,[CreateUserID]
				  ,[CreateDate]
				  ,[UpdateUserID]
				  ,[UpdateDate]
			  FROM [dbo].[PRODPrettyUrl] pu
	else		

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


	END TRY

	BEGIN CATCH
		RETURN 10802
	END CATCH 
END

GO
GRANT EXECUTE ON [dbo].[Core_PrettyURL_GetAll] TO [websiteuser_role]
GO
