with facebook as
(
	select f.ad_date,
		facebook_campaign.campaign_name,
		facebook_adset.adset_name,
		f.spend,
		f.impressions,
		f.reach,
		f.clicks,
		f.leads,
		f.value,
		f.url_parameters		
	from 
		facebook_ads_basic_daily f
	inner join 
		facebook_adset on facebook_adset.adset_id =f.adset_id
	inner join 
		facebook_campaign on facebook_campaign.campaign_id =f.campaign_id 
	union all 
	select *
	from google_ads_basic_daily
		)
	select 
	facebook.ad_date ,
	facebook.campaign_name,
	coalesce (facebook.spend,0) as total_spend,
	coalesce(facebook.impressions,0) as total_impressions,
	coalesce(facebook.clicks,0) as total_clicks,
	coalesce(facebook.leads,0) as total_leads,
	coalesce(facebook.spend/facebook.clicks) as CPC,
	coalesce(facebook.spend*1000,0) as CPM,
	coalesce(((facebook.value)::numeric-facebook.spend)/facebook.spend*100,0) as Romi,
	coalesce((facebook.clicks::numeric/facebook.impressions)*100,0) as CTR,
	case 	
		lower(substring(facebook.url_parameters,49,length(facebook.url_parameters)))
		when '' then null
		else 	lower(substring(facebook.url_parameters,49,length(facebook.url_parameters)))
		end utm_campaign,
	facebook.url_parameters
	from facebook
	where clicks >0 and impressions >0 and spend >0
