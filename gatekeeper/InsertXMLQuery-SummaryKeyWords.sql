/*This insert statement is needed for the GateKeeper summary extractor to correctly extract the new SummaryKeyWords from the CDR Data*/

insert into XMLQuery (Name, QueryText, Comments, UpdateDate, UpdateUserID)
	  values ('SummaryKeyWords', './SummaryMetaData/SummaryKeyWords', null, GETDATE(),'dbo')
	  