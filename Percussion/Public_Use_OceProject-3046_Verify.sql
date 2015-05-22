-- S: L:\OCPL\ODDC\CPSB\BK\ForRoy\Percussion\Public_Use_OceProject-3046_Verify.sql.
-- F: Verify thet Public_Use_OceProject-3046.sql has run OK.
--    If Public_Use not 1, error message in red like:
--       Msg 50000, Level 16, State 126, Line 40
--       Public_Use not 1 for some pdqCancerInfoSummary records.
--
Set NoCount On
Use [Percussion]
Select top 1000
       Derived.*
   from (
      Select
             RowId                        = ROW_NUMBER ()
                                               over (Partition by CG.ContentId     -- Senior key.
                                                     order by CG.RevisionId desc), -- Junior key.
             CG.CONTENTID,
             CG.REVISIONID,
             CG.PUBLIC_USE,
             CG.LONG_TITLE,
             CG.SHORT_TITLE,
             CG.LONG_DESCRIPTION,
             CG.SHORT_DESCRIPTION,
             CG.META_DESCRIPTION,
             CG.META_KEYWORDS,
             CG.DO_NOT_INDEX,
             CG.PRETTY_URL_NAME,
             CG.PUBLIC_ARCHIVE,
             CG.BROWSER_TITLE,
             CG.CARD_TITLE
         FROM [Percussion].[dbo].CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1  as CG
         inner join dbo.CONTENTSTATUS        as CS
            on (CG.CONTENTID                 = CS.CONTENTID)
        where (CS.CONTENTTYPEID              = (Select CT.CONTENTTYPEID
                                                   from dbo.CONTENTTYPES               as CT
                                                   where CT.CONTENTTYPENAME            =
                                                            'pdqCancerInfoSummary'))
        )                                 as Derived
  where (Derived.RowId                 <= 1)
    and (Derived.PUBLIC_USE            <> 1)
  order by Derived.CONTENTID,
           Derived.REVISIONID desc;
If ROWCOUNT_BIG () <> 0
   RaisError ('Public_Use not 1 for some pdqCancerInfoSummary records.', 16, 126);
Else
   Print 'All OK';