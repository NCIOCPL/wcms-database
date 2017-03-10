create table dbo.ctPrintResultCache
(printid UNIQUEIDENTIFIER 
        CONSTRAINT DF_printid DEFAULT newsequentialid(),
cachedate datetime CONSTRAINT DF_cachedate DEFAULT getdate(),
content nvarchar(max),
searchparams nvarchar(max),
isLive bit constraint df_isLive default 1,
 CONSTRAINT [PK_printresultcache] PRIMARY KEY CLUSTERED 
(
	[printid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
)
