insert into dbo.XMLQuery([name], queryText) values('MobileURL', './SummaryMetaData/MobileURL')
insert into dbo.XMLQuery([name], queryText) values('SummaryBaseMobileURL', 'xref')

update xmlquery
set QueryText= '//Summary/SummarySection[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices))]'
where name ='SummaryTopSection'


update xmlquery
set QueryText= './/SummarySection[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices)) and (count(ancestor::*) = count(ancestor::*[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices))]))]'
where name ='SummarySubSection'


update xmlquery
  set QueryText= './/Table[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices)) and (count(ancestor::*) = count(ancestor::*[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices))]))]'
where name ='SummarySectionTable'


update xmlquery
  set QueryText= '//MediaLink[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices)) and (count(ancestor::*) = count(ancestor::*[(contains(concat('' '', @IncludedDevices, '' ''), concat('' '', ''{0}'', '' '')) or not(@IncludedDevices)) and (not(contains(concat('' '', @ExcludedDevices, '' ''), concat('' '', ''{0}'', '' ''))) or not(@ExcludedDevices))]))]'
where name ='SummaryMediaLink'
