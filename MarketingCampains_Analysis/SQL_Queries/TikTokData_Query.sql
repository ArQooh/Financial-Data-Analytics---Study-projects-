select * from tiktok_campaign_data
limit 100;

-- Kontrola nulových hodnôt pomocou jsonb
select
key AS column_name,
count(*) filter (where value = 'null' or value IS NULL) AS null_count
from tiktok_campaign_data as DataTable
CROSS JOIN LATERAL jsonb_each(to_jsonb(DataTable))
GROUP BY column_name
ORDER BY null_count DESC;


--zmeniť názvy stĺpcov tak, aby mali jednotný formát
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Campaign Name" TO campaign;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Campaign ID" TO campaign_id;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Ad Group Name" TO ad_group;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "By Day" TO date;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Age" TO age;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Gender" TO gender;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Cost" TO cost;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Impressions" TO impressions;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Clicks" TO clicks;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Conversions" TO conversions;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "Cost per Conversion" TO cost_per_conversion;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "CPM" TO cost_per_mille;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "CPC" TO cost_per_click;
ALTER TABLE public.tiktok_campaign_data RENAME COLUMN "CTR" TO click_through_rate;


-- Nahradenie všetkých hodnôt NULL hodnotou 0, aby boli ďalšie výpočty správne
update tiktok_campaign_data
set cost_per_conversion = 0
where cost_per_conversion IS NULL;


-- Kontrola nulových hodnôt v stĺpci cost_per_conversion
select 
count(cost_per_conversion) filter (where cost_per_conversion IS NULL)
from tiktok_campaign_data;


-- Priradiť platformu
ALTER TABLE public.tiktok_campaign_data ADD COLUMN platform TEXT;
UPDATE public.tiktok_campaign_data SET platform = 'TikTok';


-- zmeniť názvy reklamných kampaní tak, aby mali jednotný formát
select campaign, count(campaign) from tiktok_campaign_data
GROUP BY campaign;

UPDATE public.tiktok_campaign_data
SET campaign = 
	CASE WHEN campaign = 'TT_LETO26_BrandAware'
	THEN 'BrandAwareness_Leto2026'
ELSE 'ProductLaunch_Jesen2026'
END;


-- zmeniť typ údajov pri date z textu na dátum 
alter table public.tiktok_campaign_data
alter column date TYPE DATE
USING TO_DATE(date, 'MM/DD/YYYY'); 


--zmeniť typ údajov pri cost z textu na číselnú hodnotu 
alter table public.tiktok_campaign_data
alter column cost TYPE NUMERIC
USING REPLACE(cost, ' EUR', '')::NUMERIC;

alter table tiktok_campaign_data
alter column cost TYPE DOUBLE PRECISION
USING cost::DOUBLE PRECISION;
