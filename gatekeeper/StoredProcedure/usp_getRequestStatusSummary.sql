IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_getRequestStatusSummary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_getRequestStatusSummary]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

create procedure dbo.usp_getRequestStatusSummary
	@RequestID varchar(40) -- External RequestID
as
begin
set nocount on
		Declare @count int

		select @count= count(*) From RequestData where requestID = (select RequestID from Request where ExternalRequestID = @RequestID)

		select o.status as processState,
			@count as  docCount,
		(
			select r.ExternalRequestID as job,
					r.RequestType as [type],
					r.Description as description,
					r.status as status,
					r.Source as source,
					 convert(varchar(26), r.initiateDate, 126) as initiated,
					case r.status
								when 'Receiving' then null
								else convert(varchar(26), r.completeReceivedTime , 126)
					end as completion,
					r.publicationTarget 	as target,
					r.expectedDocCount		as expectedDocCount,
					@count		as actualDocCount,
					(
						select packetNumber as packet,
								groupID as [group],
								cdrID	as cdrid,
								actionType as pubType,
								(select T.[Name] from dbo.DocumentTypeMap M, dbo.DocumentType T
									 where M.DocumentTypeID = T.DocumentTypeID and
											M.dataSetID =rd.DataSetID) as [type],
								status as status,
								dependencyStatus as dependentStatus,
								location as location
						From RequestData rd
						where rd.requestID = r.requestID
						order by packetNumber
						FOR XML RAW('document'),  TYPE
					)
			From Request r 
			where r.ExternalRequestID = @RequestID
			FOR XML RAW('request'),  TYPE
		) as detailedMessage,
		o.updateDate as lastUpdateDate
		From Request o
		where o.ExternalRequestID =@RequestID
		FOR XML RAW(''), ELEMENTS , TYPE, 
		ROOT('Response')
end

GO
GRANT EXECUTE ON [dbo].[usp_getRequestStatusSummary] TO [gatekeeper_role]
GO
