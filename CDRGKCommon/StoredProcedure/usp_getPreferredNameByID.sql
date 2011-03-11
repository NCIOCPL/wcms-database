IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_getPreferredNameByID]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_getPreferredNameByID]
GO


/****** Object:   dbo.usp_usp_getPreferredNameByID   Script Date: 9/6/2005 3:20:00 PM ******/
/****** Object:   dbo.usp_getPreferredNameByID    Script Date: 9/6/2005 3:20:00 PM ******/
/*	NCI - National Cancer Institute
*	
*	File Name:	
*	usp_GetProtocolSearch.sql
*
*	Objects Used:
*
*	Change History:
*	9/9/2005 		Min	Script Created
*	To Do:
*
*/

CREATE procedure dbo.usp_getPreferredNameByID
(
	@cdrid	int =null,
	@type 	int =null,
	@diagnosisid int =null

)  
AS
BEGIN 

set nocount on
declare @CancerTypeID int ,
        @CancerTypeStageID int ,
	@cancertypename varchar (255) ,
	@CancerTypeStagename varchar (255)



if @diagnosisid is null
	begin
	set @cancertypeid = NULL
	set @cancertypeName = NULL
	set @cancertypeStageid = NULL
	set @cancertypestageName = NULL
	end
    else
		begin

				if exists (select * from dbo.cdrmenus where cdrid =  @diagnosisid )
					begin
 						exec dbo.usp_getCancertype @diagnosisid = @diagnosisid, @cancertypeid = @cancertypeid output,
							@cancertypename = @cancertypename output,
							@CancerTypeStageid = @CancerTypeStageid output,
							@cancertypeStagename = @cancertypestagename output
					end
				else
					begin
						select   @cancertypeid = @diagnosisid ,  @cancertypeStageid = @diagnosisid
						select @cancertypename  = preferredname , @cancertypeStagename = preferredname
							from dbo.terminology 
							where termid = @diagnosisid 
						
						
					end
		end



if @cdrid is null 
	begin
	select NULL as preferredname , @cancertypeid as cancertypeID, @cancertypeName as cancertypeName, @cancertypeStageid as cancerTypestageID, @cancertypestageName as cancerTypestageName
	return 0
	end
   else

		begin
		if @type = 1 or @type =5
			begin
					select top 1 preferredname as preferredname, 
						@cancertypeid as cancertypeID, @cancertypeName as cancertypeName, @cancertypeStageid as cancerTypestageID, @cancertypestageName as cancerTypestageName
					from dbo.terminology where termid = @cdrid
			return 0		
			end

		if @type = 4
			begin
					select top 1 personGivenname + ' ' + PersonSurName as preferredname ,
					@cancertypeid as cancertypeID, @cancertypeName as cancertypeName, @cancertypeStageid as cancerTypestageID, @cancertypestageName as cancerTypestageName
					from 	dbo.vwprotocolinvestigator where personid = @cdrid
				
			return 0		
			end

		if @type = 2 or @type = 3
			begin
					select top 1  name as preferredname , 
					@cancertypeid as cancertypeID, @cancertypeName as cancertypeName, @cancertypeStageid as cancerTypestageID, @cancertypestageName as cancerTypestageName				
					from dbo.organizationname where organizationid = @cdrid and type= 'OfficialName'

			return 0		
			end

		end


end

GO
GRANT EXECUTE ON [dbo].[usp_getPreferredNameByID] TO [websiteuser_role]
GO
