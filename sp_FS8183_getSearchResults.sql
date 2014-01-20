-- =============================================
-- Author:		<Jacob, Jikku, P>
-- Create date: <2011, 10, 28>
-- Description:	<Main search routine for CRD Public Search>
-- =============================================
ALTER PROCEDURE [dbo].[sp_FS8183_getSearchResults]
(
	-- Add the parameters for the stored procedure here
	@terms VARCHAR(4000), --Search terms from text box
	--@cancertype VARCHAR(255), -- This is for search results type of cancer link clicks
	@financialtype VARCHAR(255), --Search Options from checkbox selections
	@servicestype VARCHAR(255), --Search Options from checkbox selections
	@lang INT, --1 for English, 2 for Spanish
	@orgids VARCHAR(2000) OUTPUT,
	@subsearch_orgids VARCHAR(2000) = '' --Will have values if coming from a sub search
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @orgids = '' --Initialize Output variable
	DECLARE @temporgids VARCHAR(2000) = '';
	
	DECLARE @sql VARCHAR(8000);
	DECLARE @FinancialSql VARCHAR(4000);
	DECLARE @ServicesSql VARCHAR(4000);
	
	SET @FinancialSql = '';
	SET @ServicesSql = '';
	
	DECLARE @tempval VARCHAR(8000);
	
	--Variables to capture values from fn_FS8183_getLikeAnd
	DECLARE @strOrgNameSql VARCHAR(4000)
	DECLARE @strDescriptionSql VARCHAR(4000)
	DECLARE @strCancerTypeSql VARCHAR(4000)
	DECLARE @strFinancialAssistanceTypeSql VARCHAR(4000)
	DECLARE @strServiceTypeSql VARCHAR(4000)
	DECLARE @strTermsSql VARCHAR(8000);
	
	DEClARE @count INT;
	DECLARE @loopcount INT;
	DECLARE @outputid INT = 0;
	
	DECLARE @helpertable TABLE
	(
		TEMPID INT IDENTITY,
        ORGID INT,
        NameToSort VARCHAR(200),
        ORGNAME VARCHAR(200),
        ORGNAME2 VARCHAR(200),
        ACRONYM VARCHAR(50),
        ADDRESS1 VARCHAR(100),
        ADDRESS2 VARCHAR(100),
        CITY VARCHAR(50),
        [STATE] VARCHAR(5),
        ZIP VARCHAR(15),
        LOCALPHONE VARCHAR(150),
        FREELINE VARCHAR(250),
        TTY VARCHAR(250),
        EMAIL VARCHAR(100),
        URL VARCHAR(500),
        [DESCRIPTION] VARCHAR(2000),
        TOC_DESC VARCHAR(4000),
        FA_DESC VARCHAR(4000),
        OS_DESC VARCHAR(4000),
        ADDL_RESOURCES VARCHAR(4000)
	 );
	
	
	--IF @lang = 1
	--	BEGIN
			
			SET @terms = replace(@terms,'''','''''') --Clean up terms
			SET @strTermsSql = '';
			--DECLARE @tempJoin VARCHAR(4000); SET @tempJoin = '';
			--DECLARE @tempWhere VARCHAR(4000); SET @tempWhere = '';
			
			IF LEN(LTRIM(RTRIM(@terms))) > 0
				BEGIN
					--HITT 11789 SELECT	@strOrgNameSql=paramOrgName, 
					--HITT 11789		@strDescriptionSql=paramDescription,
					--HITT 11789		@strCancerTypeSql=paramCancerType,
					--HITT 11789		@strFinancialAssistanceTypeSql=paramFinancialAssistanceType,
					--HITT 11789		@strServiceTypeSql=paramServiceType
					--HITT 11789 FROM	fn_FS8183_getLikeAnd(@terms, 1);
					
					--HITT 11789 --Add CONDTIONs
					--HITT 11789 SET @strOrgNameSql = ' ' + @strOrgNameSql + ' ';
					--HITT 11789 SET @strDescriptionSql = ' OR ' + @strDescriptionSql+ ' ';
					--HITT 11789 --SET @strCancerTypeSql = ' AND ' + @strCancerTypeSql+ ' ';
					--HITT 11789 --SET @strFinancialAssistanceTypeSql = ' AND ' + @strFinancialAssistanceTypeSql+ ' ';
					--HITT 11789 --SET @strServiceTypeSql = ' AND ' + @strServiceTypeSql+ ' ';
					
					--HITT 11789 --SET @tempJoin = ' LEFT JOIN CRD_ASCCANCERTYPE d ON a.ORGID = d.ORGID AND d.TYPEOFCANCERID IN (SELECT TYPEOFCANCERID FROM CRD_LUTYPEOFCANCER E WHERE ' + @strCancerTypeSql + ' ) ' +  
					--HITT 11789 --				' LEFT JOIN CRD_ASCFINASSISTANCE f ON a.ORGID = f.ORGID AND f.FATYPEID IN (SELECT FATYPEID FROM CRD_LUFINASSISTANCE G WHERE ' + @strFinancialAssistanceTypeSql  + ' ) ' +  
					--HITT 11789 --				' LEFT JOIN CRD_ASCSERVICE h ON a.ORGID = h.ORGID AND h.SERVICEID in (SELECT SERVICEID FROM CRD_LUSERVICE I WHERE ' + @strServiceTypeSql + ' ) '
									
					--HITT 11789 SET @tempval = ' OR A.ORGID IN (SELECT ORGID FROM CRD_ASCCANCERTYPE d JOIN CRD_LUTYPEOFCANCER E ON d.TYPEOFCANCERID = e.TYPEOFCANCERID WHERE ' + @strCancerTypeSql + ' ) ' +  
					--HITT 11789				' OR A.ORGID IN (SELECT ORGID FROM CRD_ASCFINASSISTANCE f JOIN CRD_LUFINASSISTANCE G ON f.FATYPEID = G.FATYPEID WHERE ' + @strFinancialAssistanceTypeSql  + ' ) ' +  
					--HITT 11789				' OR A.ORGID IN (SELECT ORGID FROM CRD_ASCSERVICE h JOIN CRD_LUSERVICE I ON h.SERVICEID = I.SERVICEID WHERE ' + @strServiceTypeSql + ' ) '
					
					--HITT 11789 SET @strTermsSql = ' AND  (' + @strOrgNameSql + @strDescriptionSql + @tempval + ') '
					
					SET @strTermsSql = ' AND (A.Description LIKE ''%' + @terms + '%'' OR A.orgname LIKE ''%' + @terms + '%'') '; --HITT 11789 Only need the a simple match for multiple words keyword
						
				END;
			ELSE
				BEGIN --Needed for search without specifying any terms
						SET @strOrgNameSql = '';
						SET @strDescriptionSql = '';
						SET @strCancerTypeSql = '';
						SET @strFinancialAssistanceTypeSql = '';
						SET @strServiceTypeSql = '';
						SET @strTermsSql = '';
				END;
			
			
			
			
			SET @tempval = '';
			DECLARE @i_whereClause VARCHAR(4000);
			SET @i_whereClause = '';
			IF LEN(@financialtype) > 0
					BEGIN
						SET @FinancialSql = ' ' + ('F.FATYPEID IN (' + @financialtype + ')') + ' ';
						SET @tempval = ' INNER JOIN CRD_ASCFINASSISTANCE F ON F.ORGID = A.ORGID ';
					END;
				ELSE
					SET @FinancialSql = '';
				
			IF LEN(@servicestype) > 0
				BEGIN
					SET @ServicesSql = ' ' + ('H.SERVICEID IN (' + @servicestype + ')')+ ' ';
					SET @tempval = @tempval + ' INNER JOIN CRD_ASCSERVICE H ON H.ORGID = A.ORGID ';
				END;
				ELSE
					SET @ServicesSql = '';
				
			IF LEN(@financialtype) > 0 AND LEN(@servicestype) > 0
				BEGIN
					--Nov 18,2011	SET @i_whereClause = @FinancialSql + ' AND ' + @ServicesSql;
					SET @i_whereClause = @FinancialSql + ' OR ' + @ServicesSql;
					--IF LEN(@subsearch_orgids) > 0
					--	SET @i_whereClause = @FinancialSql + ' AND ' + @ServicesSql;
				END;
			ELSE IF LEN(@financialtype) > 0
				SET @i_whereClause = @FinancialSql;
			ELSE IF LEN(@servicestype) > 0
				SET @i_whereClause = @ServicesSql;
				
			IF LEN(@subsearch_orgids) > 0  
				BEGIN
					--Nov 18,2011	IF LEN(@i_whereClause) > 0
					--Nov 18,2011		SET @i_whereClause = @i_whereClause + ' AND a.orgid IN (' + @subsearch_orgids + ') ';
					--Nov 18,2011	ELSE
						SET @i_whereClause = ' a.orgid IN (' + @subsearch_orgids + ') ';
				END;
			
			IF LEN(@i_whereClause) > 0
				 SET @i_whereClause = ' WHERE ' + @i_whereClause + ' ';
				
			--Main query area
			
			SET @sql = ' ' + 
			
                 'select a.orgid, case when rtrim(ltrim(a.NameToSort)) is null  then replace(a.ORGNAME, ''"'','''') '+ 
                 
                                               'else replace(rtrim(ltrim(a.NameToSort)), ''"'','''') ' +
                                                                      'end as NameToSort, a.orgname, a.ORGNAME2, ' +
                                    'a.ACRONYM, a.ADDRESS1, a.ADDRESS2, a.CITY, ' + 
                                    'a.STATE, a.ZIP, a.LOCALPHONE, a.FREELINE, a.TTY, a.EMAIL, a.URL, a.DESCRIPTION, ' +
                                    'dbo.fn_FS8183_getTOCForOrgId(a.orgid,' + CONVERT(VARCHAR,@lang) + ') AS TOC_DESC, ' + 
                                    'dbo.fn_FS8183_getFAForOrgId(a.orgid,' + CONVERT(VARCHAR,@lang) + ') AS FA_DESC, ' +
                                    'dbo.fn_FS8183_getOSForOrgId(a.orgid,' + CONVERT(VARCHAR,@lang) + ') AS OS_DESC, ' +
                                    'dbo.fn_FS8183_getAddResForOrgId(a.orgid) AS ADDL_RESOURCES ' +
                                    'from (select a.orgid, case when a.orgname2 is null then a.orgname ' +
                                                                     'when a.orgname2 is not null then ' +
                 
                                                               'case when dbo.fn_FS_exist(rtrim(ltrim(a.orgname2))) > 0 then a.orgname2 ' +
                                                                            'else a.orgname ' +
                                                                    'end ' +
                                                               'end as NameToSort, ' +
                                                             'a.orgname, a.orgname2, a.ACRONYM, a.ADDRESS1, a.ADDRESS2, a.CITY, a.STATE, a.ZIP, a.LOCALPHONE, ' +
                                                           'a.FREELINE, a.TTY, a.EMAIL, a.URL, a.DESCRIPTION ' + 
                                                           'from crd_tblcrd a ' +
                                                          'inner join CRD_ASCPUBLINKS B ' +
                                                                     'on A.orgid = B.orgid ' +
                                                              'inner join CRD_LUPUBLINKS C ' +
                                                                  'on B.pubid = C.pubid ' +
                                                                 
                                                   'where A.deleted is null and A.org_language=' + CONVERT(VARCHAR,@lang) + @strTermsSql +
                                                   ' and c.pubdesc in (''8.1'', ''8.1s'', ''8.3'', ''8.3s'') ' +
                                                   ') a ' + @tempval + 
                               
                                      -- 'inner join CRD_ASCORGTYPE c ' +
                                      --            'on a.orgid = c.orgid ' +
                                      -- 'inner join CRD_ASCCANCERTYPE d ' +
                                      --          'on a.orgid = d.orgid ' +
                                       
												+ @i_whereClause + ' ' +
                                       'group by a.orgid, NameToSort, a.ORGNAME2, a.orgname, ' +
                                               'a.ACRONYM, a.ADDRESS1, a.ADDRESS2, a.CITY, ' +
                                                  'a.STATE, a.ZIP, a.LOCALPHONE, a.FREELINE, a.TTY, a.EMAIL, a.URL, a.DESCRIPTION ' +
                
                 
                                   'order by replace (replace(upper(a.orgname), ''THE '', ''''),''"'','''') asc ';
	
				
		--FOR TESTING PRINT (@sql); RETURN
		INSERT INTO @helpertable EXEC (@sql);
		SET @count = @@ROWCOUNT;
		
		 --SET THE OUTPUT VARIABLE VALUE
		SET @loopcount = 1;
		WHILE @loopcount <= @count
			BEGIN
				SELECT @outputid=ORGID FROM @helpertable WHERE TEMPID = @loopcount;
				IF (@loopcount = 1)
					SET @temporgids = CONVERT(VARCHAR,@outputid);
				ELSE
					SET @temporgids = @temporgids + ',' + CONVERT(VARCHAR,@outputid);
				SET @loopcount = @loopcount + 1;
			END;
		
		--END;
	--ELSE -- SPANISH LANGUAGE CODE (KEEP FOR NOW, BUT MAY NOT BE NEEDED AS FUNCTIONS TAKE CARE OF GRABBING CORRECT LOOKUP FIELDS)
	--	BEGIN
	--		SET @tempval=1;
	--	END;
		
		/*Get the Outputs*/
		SET @orgids = @temporgids; --OUTPUT VARIABLE
		SELECT * FROM @helpertable; --OUTPUT RESULTS
		
END