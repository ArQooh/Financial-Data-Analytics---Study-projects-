--Zlúčiť všetky tabuľky do jednej
select 
campaign,
ad_group,
platform,
date,
age,
gender,
cost::NUMERIC,
cost_per_mille::NUMERIC,
cost_per_click::NUMERIC,
clicks,
NULL::NUMERIC as frequency,
NULL::BIGINT as link_clicks,
click_rate::NUMERIC,
impressions,
NULL::BIGINT as viewable_impressions,
NULL::NUMERIC as reach,
conversions::NUMERIC as conversions,
cost_per_conversion::NUMERIC,
NULL::TEXT as conversion_type,
NULL::TEXT as region,
NULL::TEXT as advertiser,
NULL::TEXT as device_type
from public.tiktok_campaign_data

UNION ALL

select
campaign,
ad_group,
platform,
date,
age,
gender,
cost::NUMERIC,
NULL::NUMERIC as cost_per_mille,
cost_per_click::NUMERIC,
clicks,
frequency::NUMERIC,
link_clicks::NUMERIC,
click_rate::NUMERIC,
impressions,
NULL::BIGINT as viewable_impressions,
reach::NUMERIC,
conversions::NUMERIC,
cost_per_conversion::NUMERIC,
conversion_type,
NULL::TEXT  as region,
NULL::TEXT as advertiser,
NULL::TEXT as device_type
from public.meta_campaign_data

UNION ALL

select
campaign,
ad_group,
platform,
date,
NULL::TEXT as age,
NULL::TEXT as gender,
cost::NUMERIC,
NULL::NUMERIC as cost_per_mille,
NULL::NUMERIC as cost_per_click,
clicks,
NULL::NUMERIC as frequency,
NULL::BIGINT as link_clicks,
click_rate::NUMERIC,
impressions,
viewable_impressions,
NULL::NUMERIC as reach,
conversions::NUMERIC,
NULL::NUMERIC as cost_per_conversion,
NULL::TEXT as conversion_type,
region,
advertiser,
device_type
from public.dv360_campaign_data
----------------------------------------------------------

select * from public.merged_campaigns_media_data limit 10;


-- 1. Celkový celkový spend (v EUR) a počet konverzií po jednotlivých platformách a master kampaniach za celé obdobie
select 
platform, 
campaign, 
sum(cost::NUMERIC) as total_cost, 
sum(conversions::NUMERIC) as total_conversions, 
sum(cost_per_conversion::NUMERIC) as cost_per_conversion
from merged_campaigns_media_data
GROUP BY platform, campaign
ORDER BY sum(conversions::NUMERIC) DESC;


-- 2. Ako sa vyvíjal denný spend v čase
select 
date, 
sum(conversions::NUMERIC) as conversions,
sum(cost::NUMERIC) as spend
from merged_campaigns_media_data
GROUP BY date
ORDER BY date;

select 
date, 
sum(conversions::NUMERIC) as conversions,
sum(cost::NUMERIC) as spend,
platform
from merged_campaigns_media_data
GROUP BY date, platform
ORDER BY date;
/* Kampane začali prinášať konverzie od 2026.08.15,
keď výdavky vzrástli približne o 221%, čo predstavuje 2 300 eur,
a práve vtedy bola na platforme dv360 spustená kampaň ProductLaunch_Jesen2026 */


-- 3. Ktorá platforma mala v rámci 'Jesenný Product Launch' najlepší pomer cena/konverzia?
select 
platform, 
campaign,
sum(cost::NUMERIC) as total_spend,
round(avg(cost_per_conversion::NUMERIC), 2) as avg_spend_per_conversion,
sum(conversions::NUMERIC) as total_conversions
from merged_campaigns_media_data
where campaign = 'ProductLaunch_Jesen2026'
GROUP BY platform, campaign
ORDER BY total_conversions DESC
-- META mala najlepší pomer cena/konverzia v rámci 'Jesenný Product Launch'


-- 4. rebríček platforiem podľa CPA pomocou RANK()/DENSE_RANK()
select 
platform, 
round(sum(cost_per_conversion::NUMERIC),2) as total_cost_per_conversion,
round(avg(cost_per_conversion::NUMERIC),2) as avg_cpa,
RANK() OVER (ORDER BY round(sum(cost_per_conversion::NUMERIC),2)) as cpa_rank
from public.merged_campaigns_media_data
where cost_per_conversion > 0 
GROUP BY platform
ORDER BY cpa_rank;
----------------------------------
with platform_cpa AS (
	select
	platform,
	round(sum(cost::NUMERIC) / NULLIF(sum(conversions::NUMERIC), 0), 2) AS "CPA"
	from merged_campaigns_media_data
	GROUP BY platform
)
select 
platform,
"CPA",
RANK() OVER(ORDER BY "CPA") as cpa_rank
from platform_cpa
ORDER BY cpa_rank;





