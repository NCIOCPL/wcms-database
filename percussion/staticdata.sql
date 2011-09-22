INSERT INTO dbo.PSX_ITEM_FILTER
(Filter_ID, Version, PARENT_FILTER_ID, [Name], [Description], LEGACY_AUTHTYPE)
VALUES
(-2249674427643985919, 3, null, 'publish_preview', 'Publish Preview item filter', 0)

INSERT INTO dbo.PSX_ITEM_FILTER_RULE
(FILTER_RULE_ID, VERSION, FILTER_ID, [NAME])
VALUES
(-2249674423347561568, 0, -2249674427643985919, 'Java/global/percussion/itemfilter/sys_previewFilter')