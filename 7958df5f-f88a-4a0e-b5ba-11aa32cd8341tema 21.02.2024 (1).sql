with facebook_data as (
select
fabd.ad_date,
fc.campaign_name,
fabd.spend,
fabd.impressions,
fabd.reach,
fabd.clicks,
fabd.leads,
fabd.value 
from facebook_ads_basic_daily fabd
left join facebook_adset fa on fa.adset_id=fa.adset_id
left join facebook_campaign fc on fc.campaign_id=fc.campaign_id
union 
select 
gabd.ad_date,
gabd.campaign_name,
gabd.spend,
gabd.impressions,
gabd.reach,
gabd.clicks,
gabd.leads,
gabd.value 
from google_ads_basic_daily gabd)
select 
ad_date,
campaign_name,
sum(spend) as total_spend,
sum(impressions) as impressions,
sum(reach) as reach,
sum(clicks) as clicks,
sum(leads) as leads,
sum(value) as value
from facebook_data
group by ad_date, campaign_name
order by ad_date;