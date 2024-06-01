with all_ads_data as (
	select ad_date, url_parameters, coalesce(spend, 0) as spend,  coalesce(impressions, 0) as impressions,  coalesce(reach, 0) as reach,  coalesce(clicks, 0) as clicks,  coalesce(leads, 0) as leads,  coalesce(value, 0) as value
	from facebook_ads_basic_daily fabd
	
	union all
	
	select ad_date, url_parameters, coalesce(spend, 0), coalesce(impressions, 0), coalesce(reach, 0), coalesce(clicks, 0), coalesce(leads, 0), coalesce(value, 0)
	from google_ads_basic_daily gabd
	),
	
 monthly_stats as (
	select 
		date_trunc('month', ad_date) as ad_month, 
		case
			when lower(substring(url_parameters, 'utm_campaign=([^\&]+)')) != 'nan' then decode_url_part(lower(substring(url_parameters, 'utm_campaign=([^\&]+)')))
		end as utm_campaign,
		sum(spend) as total_spend, 
		sum(impressions) as total_impressions,
		sum(clicks) as total_clicks,
		sum(value) as total_value,
		case 
			when sum(impressions) > 0 then 1000*sum(spend)/sum(impressions)
		end as cpm,
		case 
			when sum(impressions) > 0 then sum(clicks)::numeric/sum(impressions)
		end as ctr,
		case 
			when sum(spend) > 0 then sum(value)::numeric/sum(spend)
		end as romi
	from all_ads_data aad 
	group by 1,2
),

monthly_stats_with_changes as (
	select *,
		lag(romi) over(partition by utm_campaign order by ad_month desc) as previous_month_romi,
		lag(ctr) over(partition by utm_campaign order by ad_month desc) as previous_month_ctr,
		lag(cpm) over(partition by utm_campaign order by ad_month desc) as previous_month_cpm
	from monthly_stats ms
),
select *,
	case 
		when previous_month_cpm > 0 then cpm::numeric / previous_month_cpm - 1
		when previous_month_cpm = 0 and cpm > 0 then 1
	end as cpm_change,
	case 
		when previous_month_ctr > 0 then ctr::numeric / previous_month_ctr - 1
		when previous_month_ctr = 0 and ctr > 0 then 1
	end as ctr_change,
	case 
		when previous_month_romi > 0 then romi::numeric / previous_month_romi - 1
		when previous_month_romi = 0 and romi > 0 then 1
	end as romi_change
from monthly_stats_with_changes mswc;