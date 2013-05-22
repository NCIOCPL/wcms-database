IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[usp_SummaryPushCheck]') AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[usp_SummaryPushCheck]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************

	Object's name:	usp_SummaryPushCheck
	Object's type:	store proc
	Purpose:	
	Change history:	

**********************************************************************************/

CREATE PROCEDURE usp_SummaryPushCheck
	(
	@prettyURL varchar(200),
	@isSummary bit,
	@documentGUID uniqueidentifier,
	@replacementGUID uniqueidentifier = NULL,
	@LiveDuplicateURLGUID uniqueidentifier output,
	@PreviewDuplicateURLGUID uniqueidentifier output,
	@LiveDuplicateViewID uniqueidentifier output,
	@PreviewDuplicateViewID uniqueidentifier output
	)
AS
Begin
	if @isSummary =1
		begin
			select @LiveDuplicateURLGUID =	vo.objectid
			from cancerGov.dbo.prettyURL p inner join cancergov.dbo.nciview v on p.nciviewid = v.nciviewid
				inner join cancergov.dbo.viewobjects vo on vo.nciviewid = v.nciviewid
			where currentURL = @prettyURL 
				and vo.type = case right(@prettyURL, 7) when 'Patient' then 'Summary_P' else 'summary_HP' end
				and vo.objectid <> @documentGUID
				and (@replacementGUID is NULL or vo.objectid <> @replacementGUID) 
			
			select @PreviewDuplicateURLGUID =	vo.objectid
			from cancergovStaging.dbo.prettyURL p inner join cancergovStaging.dbo.nciview v on p.nciviewid = v.nciviewid
				inner join cancergovStaging.dbo.viewobjects vo on vo.nciviewid = v.nciviewid
			where currentURL = @prettyURL 
				and vo.type = case right(@prettyURL, 7) when 'Patient' then 'Summary_P' else 'summary_HP' end
				and vo.objectid <> @documentGUID
				and (@replacementGUID is NULL or vo.objectid <> @replacementGUID) 
		end
	else
		begin
			select @LiveDuplicateURLGUID =	vo.objectid
			from cancerGov.dbo.prettyURL p inner join cancergov.dbo.nciview v on p.nciviewid = v.nciviewid
				inner join cancergov.dbo.viewobjects vo on vo.nciviewid = v.nciviewid
			where currentURL = @prettyURL  and vo.type = 'document'
				and vo.objectid <> @documentGUID

			select @PreviewDuplicateURLGUID =	vo.objectid
			from cancergovStaging.dbo.prettyURL p inner join cancergovStaging.dbo.nciview v on p.nciviewid = v.nciviewid
				inner join cancergovStaging.dbo.viewobjects vo on vo.nciviewid = v.nciviewid
			where currentURL = @prettyURL  and vo.type = 'document'
				and vo.objectid <> @documentGUID
		end


		select @LiveDuplicateViewID = v.nciviewid
			from cancergov.dbo.prettyURL p inner join cancergov.dbo.nciview v on p.nciviewid = v.nciviewid
			where currentURL = @prettyURL 
					and 
					( v.ncitemplateID is NULL or v.ncitemplateID <> 'FFF2D734-6A7A-46F0-AF38-DA69C8749AD0')
					and
					v.ncisectionid <> 'F2901263-4A99-44A8-A1DA-92B16E173E86'
					


		select @PreviewDuplicateViewID = v.nciviewid
			from cancerGovStaging.dbo.prettyURL p inner join cancerGovStaging.dbo.nciview v on p.nciviewid = v.nciviewid
			where currentURL = @prettyURL 
					and 
					( v.ncitemplateID is NULL or v.ncitemplateID <> 'FFF2D734-6A7A-46F0-AF38-DA69C8749AD0')
					and
					v.ncisectionid <> 'F2901263-4A99-44A8-A1DA-92B16E173E86'

end

GO
GRANT EXECUTE ON [dbo].[usp_SummaryPushCheck] TO [gatekeeper_role]
GO
