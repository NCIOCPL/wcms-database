IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_RetrieveNCIView]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_RetrieveNCIView]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  Stored Procedure dbo.usp_RetrieveNCIView   Owner:Jhe Purpose: For admin side Script Date: 1/15/2002 16:00:49 pm ******/

CREATE PROCEDURE dbo.usp_RetrieveNCIView
	(
	@ViewId	uniqueidentifier
	)
AS
BEGIN

set arithabort ON

/*
	SELECT *
	FROM 	NCIView 
	WHERE NCIViewID = @ViewId
*/
	DECLARE @XhtmlDenied varchar(6)
	select @XhtmlDenied =[PropertyValue] from [CancerGovStaging].[dbo].[ViewProperty]
    where [NCIViewID] = @ViewId and [PropertyName] ='XHTMLDenied'
  

	if (exists (select * from CancerGov..AuditNCIView where nciviewid = @ViewId))
	BEGIN
		Declare @CreateDate varchar(40),
			@CreateUserID	varchar(40),
			@UpdateDate	varchar(40),
			@UpdateUserID	varchar(40)

		select top 1 @CreateDate = AuditActionDate, @CreateUserID =UpdateUserID
		from  CancerGov..AuditNCIView where nciviewid = @ViewId and AuditActionType='INSERT' order by AuditActionDate

		if (exists (select * from CancerGov..AuditNCIView where nciviewid = @ViewId and AuditActionType='UPDATE'))
		BEGIN
			select top 1 @UpdateDate =   AuditActionDate, @UpdateUserID = UpdateUserID
			from  CancerGov..AuditNCIView where nciviewid = @ViewId and AuditActionType='UPDATE' order by AuditActionDate Desc
			
			select *,  'Last modified by ' + @UpdateUserID + ' on ' +@UpdateDate + '.  Created by ' + @CreateUserID + ' on '+  @CreateDate as 'UpdateInfo' , dbo.udf_ViewXHTML_Valid(nciviewid, N'C:\\Temp\xhtml1-transitional.dtd') as 'isValidXHTML', @XhtmlDenied as XhtmlDenied
			from NCIView WHERE NCIViewID = @ViewId

		END
		ELSE
		BEGIN
			select *, 'Created by ' + @CreateUserID + ' on '+ @CreateDate as 'UpdateInfo' , dbo.udf_ViewXHTML_Valid(nciviewid, N'C:\\Temp\xhtml1-transitional.dtd') as 'isValidXHTML', @XhtmlDenied as XhtmlDenied
			from NCIView WHERE NCIViewID = @ViewId
		END
	END
	ELSE
	BEGIN	
		SELECT *, '' as 'UpdateInfo', dbo.udf_ViewXHTML_Valid(nciviewid, N'C:\\Temp\xhtml1-transitional.dtd') as 'isValidXHTML', @XhtmlDenied as XhtmlDenied
		FROM 	NCIView 
		WHERE NCIViewID = @ViewId
	END
	
END
GO
GRANT EXECUTE ON [dbo].[usp_RetrieveNCIView] TO [webadminuser_role]
GO
