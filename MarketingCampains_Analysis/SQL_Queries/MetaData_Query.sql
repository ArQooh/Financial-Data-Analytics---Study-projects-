select * from public.meta_campaign_data limit 100;


-- Kontrola nulových hodnôt pomocou jsonb
select
key AS column_name,
count(*) filter (where value = 'null' or value IS NULL) AS null_count
from meta_campaign_data as DataTable
CROSS JOIN LATERAL jsonb_each(to_jsonb(DataTable))
GROUP BY column_name
ORDER BY null_count DESC;

select * from meta_campaign_data
where reach IS NULL or frequency IS NULL;


--zmeniť názvy stĺpcov tak, aby mali jednotný formát
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Campaign name" TO campaign;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Ad name" TO ad_group;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Day" TO date;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Age" TO age;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Gender" TO gender;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Reach" TO reach;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Impressions" TO impressions;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Clicks (All)" TO clicks;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Frequency" TO frequency;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Link clicks" TO link_clicks;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "CTR (link click-through rate)" TO click_through_rate;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "CPC (cost per link click) (EUR)" TO cost_per_click;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Amount spent (EUR)" TO cost;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Results" TO conversions;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Cost per results" TO cost_per_conversion;
ALTER TABLE public.meta_campaign_data RENAME COLUMN "Result type" TO conversion_type;


-- Nahradenie všetkých hodnôt NULL hodnotou 0, aby boli ďalšie výpočty správne
update meta_campaign_data
set conversions = 0
where conversions IS NULL;

update meta_campaign_data
set cost_per_conversion = 0
where cost_per_conversion IS NULL;

update meta_campaign_data
set conversion_type = null
where conversions = 0;


-- Priradiť platformu
ALTER TABLE public.meta_campaign_data ADD COLUMN platform TEXT;
UPDATE public.meta_campaign_data SET platform = 'META';

-- zmeniť názvy reklamných kampaní tak, aby mali jednotný formát
UPDATE public.meta_campaign_data
SET campaign = 
	CASE WHEN campaign = 'SK_BrandAwareness_Leto26_META'
	THEN 'BrandAwareness_Leto2026'
ELSE 'ProductLaunch_Jesen2026'
END;

-- zmeniť typ údajov pri date z textu na dátum 
alter table public.meta_campaign_data
alter column date TYPE DATE
USING TO_DATE(date, 'YYYY/MM/DD'); 