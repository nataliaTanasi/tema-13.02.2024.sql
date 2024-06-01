SELECT ad_date, campaign_id,sum(spend) as total_spend, 
sum(impressions) as total_impressions,
sum(clicks) as total_clicks,   
sum(value) as total_value,
sum(spend)/sum(clicks) as CPC,
sum(spend)*1000 as CPM,
(sum(value)-sum(spend))*100%
sum(clicks) ::numeric/sum(impressions)
from facebook_ads_basic_daily 
where clicks >0 and impressions >0 and spend >0
group by ad_date, campaign_id 
order by ad_date desc;