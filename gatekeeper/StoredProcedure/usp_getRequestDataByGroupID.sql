IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_getRequestDataByGroupID]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_getRequestDataByGroupID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure dbo.usp_getRequestDataByGroupID
@requestID int,
@groupID varchar(max) = NULL
	as
	begin
	set nocount on
			select 
				RequestDataID, 
				RequestID, 
				PacketNumber, 
				ActionType, 
				DataSetID,
				CDRID, 
				CDRVersion, 
				ReceivedDate, 
				Status, 
				DependencyStatus,
				Location, 
				groupID,
				NULL as Data
		from dbo.requestData 
		where 
			requestID = @requestID and
				(@groupID is NULL or
					groupid in 
					(select item from dbo.udf_ListToBigInt(@groupID, ','))
				 )

end

GO
GRANT EXECUTE ON [dbo].[usp_getRequestDataByGroupID] TO [gatekeeper_role]
GO
