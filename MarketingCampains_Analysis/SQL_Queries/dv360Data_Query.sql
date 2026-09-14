select * from public.dv360_campaign_data limit 100;


-- Kontrola nulových hodnôt pomocou jsonb
select
key AS column_name,
count(*) filter (where value = 'null' or value IS NULL) AS null_count
from dv360_campaign_data as DataTable
CROSS JOIN LATERAL jsonb_each(to_jsonb(DataTable))
GROUP BY column_name
ORDER BY null_count DESC;

--zmeniť názvy stĺpcov tak, aby mali jednotný formát
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Advertiser" TO advertiser;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Campaign" TO campaign;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Line Item" TO ad_group;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Date" TO date;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Device Type" TO device_type;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Region" TO region;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Impressions" TO impressions;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Clicks" TO clicks;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Click Rate" TO click_rate;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Total Media Cost (Advertiser Currency)" TO cost;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Total Conversions" TO conversions;
ALTER TABLE public.dv360_campaign_data RENAME COLUMN "Active View Viewable Impressions" TO viewable_impressions;


-- Nahradenie všetkých hodnôt NULL hodnotou 0, aby boli ďalšie výpočty správne
select * from dv360_campaign_data
where conversions > 0;
/* Rozhodol som sa ponechať všetky hodnoty NULL ako neznáme, 
keďže v stĺpci „conversions“ v databáze sa nachádzajú iba nulové hodnoty */


-- Priradiť platformu
ALTER TABLE public.dv360_campaign_data ADD COLUMN platform TEXT;
UPDATE public.dv360_campaign_data SET platform = 'dv360';

-- zmeniť názvy reklamných kampaní tak, aby mali jednotný formát
select campaign from dv360_campaign_data
GROUP BY campaign;

UPDATE public.dv360_campaign_data
SET campaign = 'ProductLaunch_Jesen2026';


-- zmeniť typ údajov pri date z textu na dátum 
alter table public.dv360_campaign_data
alter column date TYPE DATE
USING TO_DATE(date::TEXT, 'YYYYMMDD'); 

-- zmeniť typ údajov pri click_rate z textu na číselnú hodnotu  
alter table dv360_campaign_data
alter column click_rate TYPE DOUBLE PRECISION 
USING REPLACE(click_rate, '%', '')::DOUBLE PRECISION 

-- prepočítať USD na EUR a nahradiť
UPDATE public.dv360_campaign_data
SET cost = cost*0.92

UPDATE public.dv360_campaign_data
SET cost = round(cost::NUMERIC, 2)
