--select 
--'select ''' + category_name + ''',''' + prettyurl + '''' + char(13) + ' union '
--from topicsearchurl

--if object_id('topicsearchURL') is  null
--	select * into topicsearchURL from
--	(
--	select 'AIDS-Related Cancers' as category_name,'/cancertopics/litsearch/aids-related' as prettyurl  union 
--	select 'Breast Cancer','/cancertopics/litsearch/breast'  union 
--	select 'Cancer Genetics','/cancertopics/litsearch/genetics'  union 
--	select 'Cardiovascular Cancers','/cancertopics/litsearch/cardiovascular'  union 
--	select 'Endocrine Cancers','/cancertopics/litsearch/endocrine'  union 
--	select 'Gastrointestinal Cancers','/cancertopics/litsearch/gastrointestinal'  union 
--	select 'Gynecologic Cancers','/cancertopics/litsearch/gynecologic'  union 
--	select 'Head and Neck Cancers','/cancertopics/litsearch/head-and-neck'  union 
--	select 'Hematologic/Blood','/cancertopics/litsearch/hematologic'  union 
--	select 'Male Reproductive Cancers','/cancertopics/litsearch/male-reproductive'  union 
--	select 'Metastatic Cancer','/cancertopics/litsearch/metastatic'  union 
--	select 'Neurologic Cancers','/cancertopics/litsearch/neurologic'  union 
--	select 'Sarcoma','/cancertopics/litsearch/sarcoma'  union 
--	select 'Skin Cancers and Melanoma','/cancertopics/litsearch/skin-and-melanoma'  union 
--	select 'Thoracic Cancers','/cancertopics/litsearch/thoracic'  union 
--	select 'Tobacco','/cancertopics/litsearch/tobacco'  union 
--	select 'Urinary Tract Cancers','/cancertopics/litsearch/urinary-tract'  
--	)a
--GO
--Topic Search Categories
drop procedure Mig_TopicSearchCategory
go
create procedure Mig_TopicSearchCategory
as
BEGIN
select 
      ListID as viewid,
      ('Cancer Topic Searches: ' + ListName) as long_title,
      ('Cancer Topic Searches: ' + ListName) as short_title,
      ListName as category_name,
	  right(u.prettyurl, charindex('/', reverse(u.prettyurl))-1) as pretty_url_name,
      ListDesc as category_subheading,
      1 as do_not_index,
      0 as email_available,
      0 as print_available,
      0 as share_available,
      u.prettyurl as prettyurl
from LIST l JOIN ViewObjects vo ON vo.objectID = l.listid 
inner join topicsearchurl u on u.category_name = listname
where vo.NCIViewID = '55994CFF-4FA3-461D-BE24-2F037106C8AB'
order by 4


END

GO

--Topic Searches
drop function dbo.Mig_TopicSearch
go
create function dbo.Mig_TopicSearch(@viewid uniqueidentifier)
returns @r table(topicSearchID uniqueidentifier, 
topic_search_name  varchar(256), topic_search_query nvarchar(max))
as 
BEGIN
insert into @r
SELECT NCIViewID as TopicSearchID, 
TopicName as topic_search_name,
TopicSearchTerm as topic_search_query 
FROM ViewObjects vo
JOIN TSTopics ts
ON vo.objectid = ts.topicid
WHERE NCIViewID in (
      SELECT NCIViewID
      FROM ListItem li
      where ListID = @viewid --Topic Search ID
)
return
END
GO

