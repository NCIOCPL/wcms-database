sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  percCancergov\tables\ctprintcache.sql
sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  percCancergov\tables\ctprintresultcache.sql
sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  percCancergov\types\udt_trialids.sql
sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  percCancergov\storedprocedures\ct_cleanPrintresultcache.sql
sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  percCancergov\storedprocedures\ct_getCTPrintresultcache.sql
sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  percCancergov\storedprocedures\ct_insertCTPrintresultcache.sql
sqlcmd -l 0 -S %1  -E -I -d percCancergov -i  monthlyCleanJob.sql
