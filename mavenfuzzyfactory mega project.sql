/* Project objective
The SITUATION :-
Maven Fuzzy Factory has been live for ~8months, and the CEO is due to present company performance metrics to the board next week.
I as an analyst, will be the one tasked with preparing relevant metrics to show the company’s promising growth. */

/* Analyses Requests From the CEO
1.Can you help me understand where the bulk of our website sessions are coming from, through yesterday? I’d like to see a breakdown by UTM source , 
campaign and referring domain. */

use mavenfuzzyfactory;

select * from website_sessions;

SELECT utm_source, utm_campaign, http_referer, count(website_session_id) as sessions_count 
FROM mavenfuzzyfactory.website_sessions
where created_at < '2012-04-12'
group by utm_source, utm_campaign, http_referer
order by sessions_count desc;

/*Gsearch nonbrand is the primary driver of our business. This is the major traffic source. */

-- 2. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?

SELECT max(dayname(created_at)) as max_date FROM website_sessions;
SELECT * FROM mavenfuzzyfactory.website_sessions;

select 
year(ws.created_at) yr, 
month(ws.created_at) mn, 
count(distinct(ws.website_session_id)) as sessions,
count(distinct(o.order_id)) as orders,
count(distinct(o.order_id))/count(distinct(ws.website_session_id)) as conv_rate
from website_sessions ws
left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-12' and utm_source = 'gsearch'  
group by yr,mn;

/*
[Results/Insights]:
The session volume has demonstrated remarkable growth.
In the initial month, there were 1860 sessions, which has since increased by approximately 378% to reach 8889 sessions.

Orders have experienced substantial growth.
In March or the 1st full month of April, there were only 92 orders. Currently, we have witnessed nearly 300% increase in orders, resulting in approximately 4 times that order volume.

The conversion rate initially stood at around 2.6% during the first 3 months.
By the final month, it had improved by more than 53% over the past 5 months to reach over 4% in the current month.

Overall, the business is seeing positive results in terms of both website traffic, orders and conversions. */

/* 3. Based on the findings, it seems like we should probably dig into gsearch non-brand a bit deeper to see what we can do to optimize there. 
Since gsearch nonbrand is our major traffic source, so we need to understand if those sessions are driving sales.
Could you please calculate the conversion rate (CVR) from session to order? 
Based on what we’re paying for clicks, we’ll need a CVR of at least 4% to make the numbers work.
If we’re much lower, we’ll need to reduce bids. If we’re higher, we can increase bids to drive more volume. */

-- filter gsearch, nonbrand 
-- are sessions driving sales
-- converstion rate from session to order
-- cvr > 0.04

use mavenfuzzyfactory;

SELECT 
    COUNT(DISTINCT ws.website_session_id) AS total_sessions, 
    COUNT(DISTINCT o.order_id) AS total_orders,
    (COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id)) * 100 AS conversion_rate_percentage
FROM 
    website_sessions ws
LEFT JOIN 
    orders o ON ws.website_session_id = o.website_session_id
WHERE 
    ws.created_at < '2012-04-14' AND
    ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand';

/* [Results/Insights]:
Our analysis reveals our current conversion rate of 2.9%, which falls short of the 4% required threshold necessary for economic viability.
So, it is recommended that we make adjustments to our search bid strategy since we’re over spending based on the current conversion rate.
Dialing down our search bids slightly can help optimize our spending in alignment with the current conversion rate.
This strategy is expected to result in cost savings.
Based on this conversion rate analysis, we are going to bid down gsearch non-brand. */

/* 4.Let’s see a monthly trend for Gsearch, splitting out non-brand and brand campaigns separately. 
I am wondering if brand is picking up at all? If so, this is a good story to tell to investors. */

-- where gsearch, case when nonbrand and brand
-- count orders, count website_session_id

select 
year(ws.created_at) yr, 
month(ws.created_at) mn, 
count(distinct case when utm_campaign = 'nonbrand' then ws.website_session_id else null end) as nonbrand_sessions,
count(distinct case when utm_campaign = 'nonbrand' then o.order_id else null end) as nonbrand_orders,
count(distinct case when utm_campaign = 'brand' then ws.website_session_id else null end) as brand_sessions,
count(distinct case when utm_campaign = 'brand' then o.order_id else null end) as brand_orders
from website_sessions ws
left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27' AND
    ws.utm_source = 'gsearch'
    group by yr,mn;
    
/*    [Results/Insights]:
Overall, the trend for brand sessions and brand orders is positive.
Both metrics have been increasing steadily over the past 8 months, which suggests that the brand is becoming more well-known and trusted by consumers.

Brand campaigns are when people search for our company’s name on search engines and hit the our Ad (- yes, companies bid on their own terms, to maintain a competitive edge or largely to get ahead of competitors).
Our board of directors is interested in understanding whether our customer acquisition strategy will always depend on paid advertising, or if our brand is gradually gaining strength and recognition over time, a concept referred to as ‘brand traction.’
Brand campaigns are a good way to measure brand traction.
The fact that our brand sessions have increased dramatically is a good sign that we are building brand traction and that we may not always need to rely on paid advertising or paid traffic to attract customers.
Our investors are likely to be pleased with this result. */

/* 5. I was trying to use our site on my mobile device the other day, and the experience was not great. Could you pull conversion rates from session to order, by device type? 
If desktop performance is better than on mobile, we may be able to increase our bids for desktop specifically to get more traffic volume?

- conversion rate from session to order by device type 

select 
ws.device_type,
count(distinct ws.website_session_id) as total_sessions,
count(distinct o.order_id) as total_orders,
count(distinct o.order_id)/count(distinct ws.website_session_id) as cvr
from website_sessions ws
left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-05-11' and ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by device_type;


/* [Results/Insights]:
There is significant variation in conversion rates by device type, with desktop devices having a conversion rate of 3.7% and mobile devices having a conversion rate of 0.96%.
That means, Desktop devices convert sessions to orders at a rate of 285.42% higher than mobile devices.
This means that for every 100 mobile sessions which convert to orders, 285 more desktop sessions will convert in addition to taking mobile ones into account.
Businesses may also want to invest more in desktop advertising since desktop sessions are more likely to convert to orders.
So based on this analysis, I think we should plan to increase our bids for desktop advertising.
By increasing our bids, we will achieve a higher ranking in search engine auctions, which I believe should lead to a sales boost. */

/* 6. After your device level analysis of conversion rates, we realized desktop was doing well, so we bid our gsearch nonbrand desktop campaigns up on 2012-05-19. 
So while we are on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? */

select 
year(ws.created_at) yr, 
month(ws.created_at) mn, 
count(distinct case when ws.device_type = 'desktop' then ws.website_session_id else null end) as desktop_sessions,
count(distinct case when ws.device_type = 'mobile' then ws.website_session_id else null end) as mobile_sessions,
count(distinct case when ws.device_type = 'desktop' then o.order_id else null end) as desktop_orders,
count(distinct case when ws.device_type = 'mobile' then o.order_id else null end) as mobile_orders,
round(count(distinct case when ws.device_type = 'desktop' then ws.website_session_id else null end)/count(distinct case when ws.device_type = 'mobile' then ws.website_session_id else null end),2) as sessions_split,
round(count(distinct case when ws.device_type = 'desktop' then o.order_id else null end)/count(distinct case when ws.device_type = 'mobile' then o.order_id else null end),2) as orders_split
from website_sessions ws
left join orders o on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27' and ws.utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by yr,mn;




/* [Results/Insights]:
What we see here is a lot more desktop sessions than mobile from the very start itself.
From the beginning, it was a little less than a 2:1 ratio (desktop:mobile), but at the end of this time period, we’ve got more than a 3:1 ratio.
For orders, we had a 5:1 ratio at the beginning of the period and the desktop:mobile ratio had increased to 10:1 by the end.
This means that desktop users are now 3 times more likely to visit our website and 10 times more likely to place an order than mobile users.
The slight increase in sessions in favor of desktop must take the fact that we bid our gsearch non-brand desktop campaigns up on 2012–05–19. */

/* 7.I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels. */

select 
utm_source,
count(utm_campaign),
count(http_referer)
from website_sessions 
where created_at < '2012-11-27'
group by utm_source;

/* 7.I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels. */

select
year(created_at) as yr,
month(created_at) as mn,
count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions,
count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions,
count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end) as organic_search_sessions,
count(distinct case when utm_source is null and http_referer is null then website_session_id else null end) as direct_sessions
from website_sessions
group by yr, mn;

/* [Results/Insights]:
We see here our gearch paid sessions building over time, we’ve got bsearch sessions taking off quite a bit more than they were at the beginning as well.
We have organic search sessions and direct type-in sessions growing over time.

In particular, the board and CEO are going to be very excited about organic search and direct type-in sessions building up because these represent sessions that the company is not paying for.
In contrast, with the gsearch/bsearch paid sessions, there is a cost of customer acquisition for any orders that come in and paying for that marketing spend, it eats into the margin.
However, there’s no additional variable cost for paying for that direct type-in and organic search traffic. */

/* 8.Could you help me get my head around the site by pulling
the most viewed website 'pages, ranked by session volume? */

-- pageview url, count(website_session_id), 


select pageview_url ,count(distinct website_session_id) as session_volume from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by session_volume desc;

/* [Results/Insights]:
The homepage, the products page, and the Mr. Fuzzy page attract the majority of our website traffic.
It is important now to learn more about how traffic flows through our website, including which pages are most popular, how visitors navigate between pages, and where they leave the website.

Looks like our CVR was low due to the fact that very less number of sessions billing page and hitting order page.
We need to see if the most-viewed website pages are our top entry pages as well. */

/* 9.Would you be able to pull a list of the top entry pages ? 
I want to confirm where our users are hitting the site. If you could pull all entry pages and rank them on entry volume , that would be great. */

/* [Results/Insights]:
Looks like our traffic all comes in through the homepage right now!
So that is the very first place where customer is seeing our website for the first time.
Seems pretty obvious that this is the page where we should focus our efforts to improve the user experience.
I believe it is imperative to analyze landing page performance, for the homepage specifically. */

/* 10.The other day you showed us that all of our traffic is landing
on the homepage right now. We should check how that landing page is performing.
Can you pull bounce rates for traffic landing on the homepage? 
I would like to see three numbers… Sessions , Bounced Sessions , and % of Sessions which Bounced (aka “Bounce Rate”). */

use mavenfuzzyfactory;

-- find the first pageview id for each session all clear

with first_page_visited as (select 
website_session_id,
min(website_pageview_id) as first_pageview_id
from website_pageviews
where created_at < '2012-06-14'
group by website_session_id),

-- for each first pageview id pageview url should be homepage

first_homepage_sessions as (select 
fpv.website_session_id
from first_page_visited fpv 
inner join website_pageviews wp on fpv.website_session_id = wp.website_session_id
where 
wp.pageview_url= '/home'), 

-- count total pageviews for each session landing on homepage

count_homepage_sessions as (select  
count(wp.website_pageview_id) pageview_count, 
fps.website_session_id
from first_homepage_sessions fps
inner join website_pageviews wp on wp.website_session_id = fps.website_session_id
group by fps.website_session_id),

bounced_sessions as (select website_session_id 
from count_homepage_sessions
where pageview_count = 1), 

total_sessions as (
select 
distinct website_session_id as total_sessions
from website_pageviews
where pageview_url = '/home' and created_at < '2012-06-14')

select 
count(distinct bs.website_session_id) bounced_sessions,
count(ts.total_sessions) total_sessions,
count(distinct bs.website_session_id)*100/count(ts.total_sessions) as bounce_percent
from total_sessions ts
left join bounced_sessions bs on ts.total_sessions = bs.website_session_id;

/* 11.Based on your bounce rate analysis, we ran a new custom landing page (/lander 1) in a 50/50 test against the homepage (/home) for our gsearch nonbrand traffic.
Can you pull bounce rates for the two groups so we can evaluate the new page? 
Make sure to just look at the time period where /lander 1 was getting traffic , so that it is a fair comparison. */

use mavenfuzzyfactory;
-- filtered sessions for gsearch and nonbrand
    
-- main code 

SELECT
    created_at AS first_created_at,
    website_pageview_id AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
ORDER BY 1 ASC
LIMIT 1; 

DROP TABLE IF EXISTS first_pageview_landerl;

CREATE TEMPORARY TABLE first_pageview_landerl
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
    ON website_pageviews.website_session_id = website_sessions.website_session_id
    AND website_pageviews.created_at < '2012-07-28'
    AND website_pageviews.website_pageview_id > 23504 
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
    website_pageviews.website_session_id;

SELECT * FROM first_pageview_landerl;

CREATE TEMPORARY TABLE sessions_w_landing_page_lander
SELECT 
    first_pageview_landerl.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageview_landerl -- Corrected this line
LEFT JOIN website_pageviews
    ON first_pageview_landerl.min_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');

CREATE TEMPORARY TABLE bounced_sessions_lander AS
SELECT
    sessions_w_landing_page_lander.website_session_id,
    sessions_w_landing_page_lander.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_lander
LEFT JOIN website_pageviews
    ON website_pageviews.website_session_id = sessions_w_landing_page_lander.website_session_id
GROUP BY
    sessions_w_landing_page_lander.website_session_id,
    sessions_w_landing_page_lander.landing_page
HAVING
    COUNT(website_pageviews.website_pageview_id) = 1;
    
SELECT

sessions_w_landing_page_landerl.landing_page,

COUNT(DISTINCT sessions_w_landing_page_landerl.website_session_id) AS sessions,

COUNT(DISTINCT bounced_sessions_landerl.website_session_id) AS bounced_sessions,

COUNT(DISTINCT bounced_sessions_landerl.website_session_id) / COUNT(DISTINCT sessions_w_landing_page_landerl.website_session_id) AS
bounce_rate
FROM sessions_w_landing_page_lander1

LEFT JOIN bounced_sessions_landerl

ON sessions_w_landing_page_landerl.website_session_id = bounced_sessions_landerl.website_session_id

GROUP BY

sessions_w_landing_page_landerl.landing_page;

SELECT
    sessions_w_landing_page_lander.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_lander.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_lander.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_lander.website_session_id) / COUNT(DISTINCT sessions_w_landing_page_lander.website_session_id) AS bounce_rate
FROM sessions_w_landing_page_lander
LEFT JOIN bounced_sessions_lander
    ON sessions_w_landing_page_lander.website_session_id = bounced_sessions_lander.website_session_id
GROUP BY
    sessions_w_landing_page_lander.landing_page;
    
/* 
[Results/Insights]:
From this analysis, we can see that the custom landing page has a lower bounce rate than the homepage, which is a great success.
So it is no brainier that we now need to get campaigns updated so that all non-brand paid traffic is pointing to the new page.
I think it is important to track and confirm if our traffic volume is all running to the new custom lander after campaign updates and also keep an eye on bounce rates trends.
*/

/* 12.Could you pull the volume of paid search non-brand traffic landing on /home and /lander 1, trended weekly since June 1st? I want to confirm the traffic is all routed correctly.
Could you also pull our overall paid search bounce rate trended weekly ? 
I want to make sure the lander change has improved the overall picture. */

use mavenfuzzyfactory;

/* STEP 1: finding the first website pageviews */

CREATE TEMPORARY TABLE sessions_w_min_pv_and_view_count AS
SELECT
  website_pageviews.website_session_id,
  MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
  COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
LEFT JOIN website_pageviews
  ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
  website_pageviews.created_at > '2012-06-01'
  AND website_pageviews.created_at < '2012-08-31'
  AND website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
  website_pageviews.website_session_id
;

-- identifying the landing page
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at AS
SELECT 
  sessions_w_min_pv_and_view_count.website_session_id,
  sessions_w_min_pv_and_view_count.first_pageview_id,
  sessions_w_min_pv_and_view_count.count_pageviews,
  website_pageviews.pageview_url AS landing_page,
  website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_and_view_count
LEFT JOIN website_pageviews
  ON sessions_w_min_pv_and_view_count.first_pageview_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');


-- summarizing by week (bounce rate, sessions to each lander)
SELECT
MIN(DATE(session_created_at)) AS week_start_date,
COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate,
COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM sessions_w_counts_lander_and_created_at
GROUP BY
YEARWEEK(session_created_at);

/*
[Results/Insights]:
The 3 month data shows that both the previous home page and the custom landing page received traffic for a period of time, before we fully switched over to the custom landing page, as intended.

The overall average bounce rate has been trending downwards over the past 3 months.
The overall average bounce rate has decreased by 11.34 % over past 3 months.
Since then, we have observed a 3.218% decrease in the overall bounce rate. It means, the average bounce rate is now 3.218% lower than it was during the test was being conducted. In other words, the test has lowered the average bounce rate by 3.218%.
This indicates that the custom landing page is more engaging and effective at keeping visitors on the site.
The bounce rate has been relatively stable over the past few weeks, with a slight increase of almost 0.15 % in the last week.
*/

/* For the gsearch lander test, please estimate the revenue that test earned us. 
Hint: Look at the increase in CVR from the test (Jun 19 Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
* the website manager ran a new custom landing page (/lander-1) in a 50/50 A/B testing against the homepage(/home) for the gsearch nonbrand traffic from Jun 19 — July 28.
In other words: Compare the new lander with the previous lander, which one makes us more money? How much more? Quantify this in terms of monthly revenue. */


use mavenfuzzyfactory;

SELECT
MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

CREATE TEMPORARY TABLE first_test_pageviews
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
AND website_pageviews.website_pageview_id > 23504 -- first page_view
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY
website_pageviews.website_session_id;

-- next, we ring in the ng page to each session, like last but restricting to home or er-1 this time

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT
first_test_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page

FROM first_test_pageviews

LEFT JOIN website_pageviews

ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id

WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
nonbrand_test_sessions_w_landing_pages.website_session_id,
nonbrand_test_sessions_w_landing_pages.landing_page,
orders.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages
LEFT JOIN orders
ON orders. website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id;

-- to find the difference betwee [ version rate CVR) betwee tw ders test

select 
landing_page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1;

/* [Results/Insights]:
The results table displays the conversion rate (CVR) for both landing pages.
'/home' and '/lander-1' conv_rate difference = 0.0406 - 0.0318 = 0.0088
That means, Lander-1 has a slightly higher CVR, generating approximately 0.0088% more orders per session than the home page.
After we get the lift in CVR, we need to find the most recent pageview for gsearch nonbrand where the traffic was sent to '/home'. */


/* In marketing, “lift” represents an increase in sales in response to some form of advertising or promotion.
Monitoring, measuring, and optimizing lift may help a business grow more quickly. */

-- landing ¢ )st recent pag " € h nonbrand wt the 1 ff < ent 1

SELECT
MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home'
AND website_sessions.created_at < '2012-11-27';

/* 
“most_recent_gsearch_nonbrand_home_session” is 17145.
This is the highest session ID where we had gsearch nonbrand traffic going to ‘/home/’ page.
Since then, all of this traffic has been redirected to /lander-1.
Next, we can attempt to determine the number of sessions that have occurred since this traffic reroute.

*/

-- count the uml sessions

SELECT
COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
AND website_session_id > 17145 
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand';

/* 

[Results/Insights]:
We had 22972 sessions since after rerouting all traffic to lander-1.

22972 (sessions) * 0.0088 (incremental conversion rate) = 202 (incremental orders) since the home page A/B test concluded.
If we talk about it in terms of orders per month, this is generating an extra 50 orders per month.
Roughly 4 months (7/29 ~ 11/27), so roughly 50 extra orders per month.

Incremental Conversion: When we talk about “incremental conversion”, we are talking about how well a new version of something converts compared to the previous version.
Conversion Rate B — Conversion Rate A = incremental conversion.

*/

/* 
14.For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to orders. 
You can use the same time period you analyzed last time (Jun 19 — Jul 28).
In the following section, I first attempted to determine which version of the pages people saw and how far they progressed through the conversion funnel.
*/

SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at AS pageview_created_at,
CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND website_sessions.created_at < '2012-07-28'
AND website_sessions.created_at > '2012-06-19'
ORDER BY
website_sessions.website_session_id,
website_pageviews.created_at;

CREATE TEMPORARY TABLE session_level_made_it_flagged

SELECT 
  website_session_id,
  MAX(homepage) AS saw_homepage,
  MAX(custom_lander) AS saw_custom_lander,
  MAX(products_page) AS product_made_it,
  MAX(mrfuzzy_page) AS mrfuzzy_made_it,
  MAX(cart_page) AS cart_made_it,
  MAX(shipping_page) AS shipping_made_it,
  MAX(billing_page) AS billing_made_it,
  MAX(thankyou_page) AS thankyou_made_it

FROM 
(
  SELECT 
    website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
  FROM website_sessions
  LEFT JOIN website_pageviews
  ON website_sessions.website_session_id = website_pageviews.website_session_id
  WHERE website_sessions.utm_source = 'gsearch'
  AND website_sessions.utm_campaign = 'nonbrand'
  AND website_sessions.created_at < '2012-07-28'
  AND website_sessions.created_at > '2012-06-19'
)
AS pageview_level
GROUP BY website_session_id;

SELECT
CASE
WHEN saw_homepage = 1 THEN 'saw_homepage'
WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
ELSE 'uh oh... check logic'
END AS segment,
COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS Tander_click_rt,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flagged
GROUP BY segment;

/*
15.I’d love for you to quantify the impact of our billing test , as well. 
Please analyze the lift generated from the test (Sep 10 Nov 10), in terms of revenue per billing page session , 
and then pull the number of billing page sessions for the past month to understand monthly impact.
* the website manager ran a new custom billing page (/billing-2) in a 50/50 A/B test against the original billing page(/billing) from Jun 19 — July 28. */

SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing','/billing-2');

SELECT
billing_version_seen,
COUNT(DISTINCT website_session_id) AS sessions,
SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM
(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS billing_version_seen,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
)
AS billing_pageviews_and_order_data
GROUP BY billing_version_seen;

SELECT
COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
AND website_pageviews.created_at BETWEEN '2012-10-27' AND '2012-11-27';

/* [Results/Insights]:

1193 billing sessions within the past month
Lift :- $8.54 per billing session
Therefore, the estimated monthly impact of the new billing page is :- 1193 * $8.54 = $10,188.22 over the past month.

*/