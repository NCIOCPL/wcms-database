-- S: L:\OCPL\ODDC\CPSB\BK\ForRoy\Percussion\Public_Use_OceProject-3046.sql.
--    https://ncisvn.nci.nih.gov/svn/oce_wcmteam/Database/branches/egyptian-mau/Percussion.
-- F: Update Public_Use field for PDQ Cancer Info summaries.
--    For: https://tracker.nci.nih.gov/browse/OCEPROJECT-3046
--    On blue:
--       Execution time    ~ 5 seconds.
--       Number of records = 3015.
Use Percussion
Set NoCount On
Declare @Latest_Revisions_To_Search    int = 1;
Declare @Loop_Count                    int = 0;
Declare @Update_Allowed                int = 0;
Set @Update_Allowed                    = 1;-- Uncomment for deployment.
   -- 0 => List only.
   -- 1 => For real: List prior, update, list after and commit.
   -- 2 => List prior, update, list after and rollback.
While @Loop_Count <= 1
   Begin
   Select Derived.*
      from (
         Select
                RowId                        = ROW_NUMBER ()
                                                  over (Partition by ContentId     -- Senior key.
                                                        order by RevisionId desc), -- Junior key.
                CONTENTID,
                REVISIONID,
                PUBLIC_USE,
                LONG_TITLE,
                SHORT_TITLE,
                LONG_DESCRIPTION,
                SHORT_DESCRIPTION,
                META_DESCRIPTION,
                META_KEYWORDS,
                DO_NOT_INDEX,
                PRETTY_URL_NAME,
                PUBLIC_ARCHIVE,
                BROWSER_TITLE,
                CARD_TITLE
           FROM [Percussion].[dbo].CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1
           where (LONG_TITLE              like '%(PDQ%')
         --where TITLE like '%(PDQ®)%'
           )                                 as Derived
     where (Derived.RowId                 <= @Latest_Revisions_To_Search)
     order by CONTENTID,
              REVISIONID desc;
   Select 'ResultSet Above'               = 'CONTENTSTATUS latest revision',
          '!'                             = @@ERROR,
          '#'                             = ROWCOUNT_BIG (),
          '@Latest_Revisions_To_Search'   = @Latest_Revisions_To_Search,
          '@Loop_Count'                   = @Loop_Count,
          '@Update_Allowed'               = @Update_Allowed;
   If @Update_Allowed = 0
      Set @Loop_Count                     = 2;
   If @Update_Allowed in (1, 2)
      Begin -- Update.
      Begin Transaction
      Update Derived
         Set PUBLIC_USE                      = 1
         from (
         Select
                RowId                        = ROW_NUMBER ()
                                                  over (Partition by ContentId     -- Senior key.
                                                        order by RevisionId desc), -- Junior key.
                CONTENTID,
                REVISIONID,
                PUBLIC_USE,
                LONG_TITLE,
                SHORT_TITLE,
                LONG_DESCRIPTION,
                SHORT_DESCRIPTION,
                META_DESCRIPTION,
                META_KEYWORDS,
                DO_NOT_INDEX,
                PRETTY_URL_NAME,
                PUBLIC_ARCHIVE,
                BROWSER_TITLE,
                CARD_TITLE
           FROM [Percussion].[dbo].CGVPUBLISHEDPAGEMETADATA_CGVPUBLISHEDPAGEMETADATA1
           where (LONG_TITLE                 like '%(PDQ%')
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
   Commit
Else
If @Update_Allowed = 2
   Rollback;