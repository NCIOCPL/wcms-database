sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\Tables\Dictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\Tables\Dictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\Tables\Dictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\Tables\DictionaryTermAlias.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\Tables\DictionaryTermAlias.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\Tables\DictionaryTermAlias.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\Types\udt_DictionaryAliasFilter.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\Types\udt_DictionaryAliasFilter.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\Types\udt_DictionaryAliasFilter.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRStagingGK\Types\udt_DictionaryTermAlias.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRStagingGK\Types\udt_DictionaryEntry.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPreviewGK -i CDRPreviewGK\StoredProcedure\usp_PushDictionaryTermToLive.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_SearchDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_SearchDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_SearchDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_GetDictionaryTermForAudience.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_GetDictionaryTermForAudience.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_GetDictionaryTermForAudience.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_GetDictionaryTerm.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_GetDictionaryTerm.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_GetDictionaryTerm.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_GetProtocolByProtocolID.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_GetProtocolByProtocolID.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_GetProtocolByProtocolID.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_SearchSuggestDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_SearchSuggestDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_SearchSuggestDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_ClearDictionaryData.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_ClearDictionaryData.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_ClearDictionaryData.sql
sqlcmd -l 0 -S %1  -E -I -d CDRLiveGK -i CDRGKCommon\StoredProcedure\usp_SearchExpandDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRPReviewGK -i CDRGKCommon\StoredProcedure\usp_SearchExpandDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRGKCommon\StoredProcedure\usp_SearchExpandDictionary.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRStagingGK\StoredProcedure\usp_getDruginfoURL.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRStagingGK\StoredProcedure\usp_SaveDictionaryTerm.sql
sqlcmd -l 0 -S %1  -E -I -d CDRStagingGK -i CDRStagingGK\StoredProcedure\usp_PushDictionaryTermToPreview.sql



sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\table\altertable.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\type\udt_taxonomyFilter.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\udf\taxonomySplit.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\view\cgvPageSearch.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\view\cgvBlog.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\view\cgvStagingPageSearch.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\view\cgvStagingBlog.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\table\cgvTaxonrelationStaging.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\table\cgvTaxonrelation.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\storedprocedure\searchFilterKeywordDate.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\trigger\tr_taxonomyInsert.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\trigger\tr_taxonomyDelete.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\trigger\tr_taxonomyInsert_staging.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\trigger\tr_taxonomyUpt_staging.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\trigger\tr_taxonomyDelete_staging.sql
sqlcmd -l 0 -S %1  -E -I -d percCancerGov -i percCancerGov\trigger\tr_taxonomyUpt.sql



sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\gaogetitemfolderpath2.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_translation.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_contentaging.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_TileAging.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_neverPublic.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_sharedcontent.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_newContent.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\updateImageSlotRelationship.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_PrimaryURL.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\percReport_SecondaryURL.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\convertToArticleNEW.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\NavUpdate.sql
sqlcmd -l 0 -S %1  -E -I -d percussion -i percussion\updateContentStateID.sql


sqlcmd -l 0 -S %1  -E -I -d gatekeeper -i gatekeeper\InsertXMLQuery-SummaryKeyWords.sql