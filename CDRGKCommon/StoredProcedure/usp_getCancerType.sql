IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_getCancerType]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_getCancerType]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/****** Object:   dbo.usp_usp_getCancerType   Script Date: 9/6/2005 3:20:00 PM ******/
/****** Object:   dbo.usp_getCancerType    Script Date: 9/6/2005 3:20:00 PM ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetCancerType.sql
*
*	Objects Used:
*
*	Change History:
*	9/19/2005 		Min	Script Created
*	To Do:
*
*/

CREATE procedure dbo.usp_getCancerType
(
	@diagnosisid	int =null ,
	@CancerTypeID int  output,
        @CancerTypeStageID int    output,
	@cancertypename varchar (255)   output,
	@CancerTypeStagename varchar (255)   output	
	)  
AS
BEGIN 
set nocount on
declare  @ParentID int 


select top 1 @ParentID = ParentID
FROM dbo.CDRMenus
WHERE CDRID = @diagnosisid

 
--IF @ParentID is not null AND @ParentID = 256085
IF @ParentID = 256085
BEGIN
            SET @CancerTypeID = @diagnosisid
	    select @cancertypeName = displayname 
	    from   dbo.cdrMenus	where cdrid = @cancertypeid and parentid = 256085
	
END
ELSE
BEGIN
            SET @CancerTypeID = @ParentID
            SET @CancerTypeStageID = @diagnosisid

	select @cancertypeName = displayname 
	    from   dbo.cdrMenus	where cdrid = @cancertypeid and parentid  =  256085
	
	 select @CancerTypeStageName = displayname
	 from dbo.cdrmenus where cdrid = @CancerTypeStageid and parentid = @cancertypeid
	
END


--print @cancertypeid
--print @cancertypename
--print @CancerTypeStageid
--print @cancerTypeStageName 
end

GO
