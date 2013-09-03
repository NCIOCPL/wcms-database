update psx_template set template = '#define($audience)##
##We check that the content type is a pdqCAncerInfoSummary
#if($sys.item.definition.name == "rx:pdqCancerInfoSummary")##
##From here the code is identical from pdqPgSynCAncerInformationSummary Template
##Check for language and what audience field and set accordingly with proper formatting
#if($sys.item.getProperty("rx:sys_lang").String == "en-us")##
#if ($sys.item.getProperty("rx:audience").String =="Patients")##
: Patient Version##
#else##
: Health Professional Version##
#end##
#else##
##check for spanish and audience field again and set the spanish equivalents
#if($sys.item.getProperty("rx:sys_lang").String =="es-us")##
#if ($sys.item.getProperty("rx:audience").String =="Patients")##
: Versión para pacientes##
#else##
: Versión para profesionales de salud##
#end##
#else##
#end##
#end##
##here if it is anything thing but a pdqCancerInfoSummary $audience is set to nothing
#else##
#end
#end##
<CatalogItem Id="$contentId" AddedDateTime="$createdDate" ModifiedDateTime="$modifiedDate">
	<ContentItem GUID="$contentId" CreatedDateTime="$createdDate" ModifiedDateTime="$modifiedDate" ContentType="text/xml" Title="${title}${audience}" TargetUrl="$syndicationURL">
        <content:SelectionSpec xmlns:content="http://www.cdc.gov/socialmedia/syndication/SyndicationContent.xsd" ClassList="syndicate"/>
        <content:Language xmlns:content="http://www.cdc.gov/socialmedia/syndication/SyndicationContent.xsd" Value="$language" Scheme="ISO 639-2"/>
        <content:Source xmlns:content="http://www.cdc.gov/socialmedia/syndication/SyndicationContent.xsd" Acronym="NCI" OrganizationName="National Cancer Institute"/>
        <content:Topics xmlns:content="http://www.cdc.gov/socialmedia/syndication/SyndicationContent.xsd" Scheme="NCI">
            <content:Topic TopicId="1" TopicName="Cancer"/>
        </content:Topics>
##To be used in a later version - when the contentbody is sent
##<content:ContentBody xmlns:content="http://www.cdc.gov/socialmedia/syndication/SyndicationContent.xsd" ContentState="Syndicated">CDataContent</content:ContentBody>
	</ContentItem>
</CatalogItem>'
where template_id = 2016

update psx_template set template = 
'#define($audience)##
##First check to see whether the language is english
#if($sys.item.getProperty("rx:sys_lang").String == "en-us")##
##check if the audience property from content type is "Patients" and set accordingly
#if ($sys.item.getProperty("rx:audience").String=="Patients")##
Patient Version##
#else##
Health Professional Version##
#end##
#else##
##if the language is set to spanish check for audience field again and set accordingly
#if($sys.item.getProperty("rx:sys_lang").String=="es-us")##
#if ($sys.item.getProperty("rx:audience").String=="Patients")##
Versión para pacientes##
#else##
Versión para profesionales de salud##
#end##
#else##
##if it gets here it just outputs the audience field from content type
#field("audience")##
#end##
#end##
#end##
<html>
<head>
#meta_header($metaDescription $longDescription $metaKeywords)##
</head>
<body>
<div class="syndicate">
<h2 id="bodyTitle">$title: $audience</h2>
#define($toc-open)
<div id="toc"><h3 id="tocTitle">$tocTitleText</h3><p id="tocBody">
#{end}
#define($toc-close)
</p></div>
#{end}
#field_if_set("$toc-open" "table_of_contents" "$toc-close" )##
<div id="bodyContent"> 
#slot("pdqCancerInformationSummaryPageSlot" "" "" "" "" "template=pdqSnSynCancerInformationSummaryPage")##
</div>
<div id="footer">
#CGOV_Syndication_Html_Date_Display()##
<span id="nciLink">This content is provided by the National Cancer Institute (<a href="http://www.cancer.gov">www.cancer.gov</a>)</span>
</div>
</div>
</body>
</html>'
where template_id = 2018