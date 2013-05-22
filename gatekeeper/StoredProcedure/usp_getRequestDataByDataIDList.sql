IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_getRequestDataByDataIDList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_getRequestDataByDataIDList]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

create procedure dbo.usp_getRequestDataByDataIDList
	@RequestDataIDList varchar(max) = NULL
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
				case isArchived 
					when 0 then 
							(select data from dbo.documentdata where requestdataID = ref.RequestDataID )
					else (select data from dbo.Archiveddocumentdata where requestdataID = ref.RequestDataID) 
					end as data
		from dbo.requestData  ref
		where 
					RequestDataID in 
					(select item from dbo.udf_ListToBigIntTable(@RequestDataIDList, ',')
				 )

end

GO
GRANT EXECUTE ON [dbo].[usp_getRequestDataByDataIDList] TO [gatekeeper_role]
GO
