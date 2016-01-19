sqlcmd -l 0 -S %1  -E -I -d Percussion -i Percussion\percReport_contentaging.sql
sqlcmd -l 0 -S %1  -E -I -d Percussion -i Percussion\percReport_PrimaryURL.sql
sqlcmd -l 0 -S %1  -E -I -d Percussion -i Percussion\percReport_translation.sql
sqlcmd -l 0 -S %1  -E -I -d Percussion -i Percussion\PercussionViewModified.sql