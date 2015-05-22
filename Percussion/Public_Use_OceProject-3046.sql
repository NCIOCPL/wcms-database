-- S: L:\OCPL\ODDC\CPSB\BK\ForRoy\Percussion\Public_Use_OceProject-3046.sql.
--    https://ncisvn.nci.nih.gov/svn/oce_wcmteam/Database/branches/egyptian-mau/Percussion.
-- F: Update Public_Use field for PDQ Cancer Info summaries.
--    For: https://tracker.nci.nih.gov/browse/OCEPROJECT-3046
--    On QA:
--       Execution time    ~ 5 seconds.
--       Number of records = 1544.
Use Percussion
Set NoCount On
Declare @ContentTypeId                 bigint;
Declare @Latest_Revisions_To_Search    int = 1;
Declare @Loop_Count                    int = 0;
Declare @Update_Allowed                int = 0;
Set @Update_Allowed                    = 3;-- Uncomment for deployment.
   -- 0 => List only.
   -- 1 => For real: List prior, update, list after and commit.
   -- 2 => List prior, update, list after and rollback.
   -- 3 => No transactions.
Select @ContentTypeId                  = CT.CONTENTTYPEID
   from dbo.CONTENTTYPES               as CT
   where CT.CONTENTTYPENAME            = 'pdqCancerInfoSummary';
Select '@ContentTypeId'                = @ContentTypeId;
While @Loop_Count <= 1
   Begin
   -- Declare @Latest_Revisions_To_Search    int = 1;
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
           where (CS.CONTENTTYPEID              = @ContentTypeId)
           )                                 as Derived
     where (Derived.RowId                 <= @Latest_Revisions_To_Search)
     order by Derived.CONTENTID,
              Derived.REVISIONID desc;
   Select 'ResultSet Above'               = 'CONTENTSTATUS latest revision',
          '!'                             = @@ERROR,
          '#'                             = ROWCOUNT_BIG (),
          '@Latest_Revisions_To_Search'   = @Latest_Revisions_To_Search,
          '@Loop_Count'                   = @Loop_Count,
          '@Update_Allowed'               = @Update_Allowed;
   If @Update_Allowed = 0
      Set @Loop_Count                     = 2;
   If @Update_Allowed in (1, 2, 3)
      Begin -- Update.
      If @Update_Allowed <> 3
         Begin Transaction
      Update Derived
         Set PUBLIC_USE                      = 1
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
           FROM [Percussion].[dbo].CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1 as CG
            inner join dbo.CONTENTSTATUS        as CS
               on (CG.CONTENTID                 = CS.CONTENTID)
           where (CS.CONTENTTYPEID              = @ContentTypeId)
           )                                 as Derived
         where (Derived.RowId                 <= @Latest_Revisions_To_Search);
         Select 'Update'                        = 'CONTENTSTATUS latest revision',
                '!'                             = @@ERROR,
                '#'                             = ROWCOUNT_BIG (),
                '@Latest_Revisions_To_Search'   = @Latest_Revisions_To_Search,
                '@Loop_Count'                   = @Loop_Count,
                '@Update_Allowed'               = @Update_Allowed;
      End;  -- Update.
   Set @Loop_Count                       += 1;
   End;
If @Update_Allowed = 1
   Commit;
Else
If @Update_Allowed = 2
   Rollback;
If @@TRANCOUNT > 0
   Begin
   Print '@@TRANCOUNT=' + cast (@@TRANCOUNT as varchar);
   Rollback;
   End;