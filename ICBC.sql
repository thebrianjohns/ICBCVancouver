/**
Title: Analysis of ICBC Accident Data for Vancouver at the Neighborhood Level
By: Brian Johns
Date Created: July 30, 2022

Summary: ICBC, as a Crown Corporation, has a significant amount of open data readily available about accidents reported within BC.
Most of the data categorizes data either by region (ie. Lower Mainland, Vancouver Island) or by municipality (ie. Vancouver, Victoria).
Fortunately, the accident data includes coordinates for each accident.
This enabled me to identify the neighborhood of each accident in Vancouver.

Goal: Identify any trends or insights that could be made about ICBC reported accidents at the neighborhood level in Vancouver.
**/

/** 

1: Input Data
Through Python, redundent data was removed and neighborhood labels were added to the ICBC data.
The data will be structured into a schema with 4 tables reflecting the Locations, Times, Tags, Descriptions of each accident.
Each row of data is information from a single reported accident.  Each accident will share the same ID number across all tables.
Description of each column of data is outlined within the creation of each table.

**/

CREATE SCHEMA vancouver_accidents;

USE vancouver_accidents;

DROP TABLE IF EXISTS tags;
CREATE TABLE tags (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, # Accident ID Number
    animal VARCHAR(255) NOT NULL, # Was an animal involved in the accident, Yes/No
    cyclist VARCHAR(255) NOT NULL, # Was a cyclist involved in the accident, Yes/No
    heavy_vehicle VARCHAR(255) NOT NULL, # Was a heavy vehicle involved in the accident, Yes/No
    intersection_crash VARCHAR(255) NOT NULL, # Did the accident occur in an intersection, Yes/No
    motorcycle VARCHAR(255) NOT NULL, # Was a motorcycle involved in the accident, Yes/No
    parked_vehicle VARCHAR(255) NOT NULL, # Did the accident involve a parked vehicle, Yes/No
    parking_lot VARCHAR(255) NOT NULL, # Did the accident occur in a parking lot, Yes/No
    pedestrian VARCHAR(255) NOT NULL, # Was a pedestratian involved in the accident, Yes/No
    mid_block VARCHAR(255) NOT NULL, # Did the accident occur mid block (no intersections), Yes/No
    crash_severity VARCHAR(255) NOT NULL # Did anyone incur any injuries in the accidents, or was there *only* property damage
    );

DROP TABLE IF EXISTS times;
CREATE TABLE times (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, # Accident ID number
    time_of_day VARCHAR(255) NOT NULL, # What was the time of accident within a 3 hour block (3:00-5:59am, 6:00-8:59am, etc)
    day_of_week VARCHAR(255) NOT NULL, # What day of the week did the accident occur (Monday, Tuesday...)
    month_of_year VARCHAR(255) NOT NULL, # What month of the year did the accident occur (January, February...)
    year_ SMALLINT NOT NULL # What year did the accident occur.  Data includes every year from 2017-2021.
    );

DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, # Accident ID number
    street_name VARCHAR(255) NOT NULL, # Name of the street where the accident occured
    cross_street VARCHAR(255) NOT NULL, # Name of the cross street where the accident occured *IF* it was at an intersection
    full_location VARCHAR(255) NOT NULL, # Full street location of the accident, including the primary street name and all cross streets
    neighborhood VARCHAR(255) NOT NULL, # Neighborhood within Vancouver that the accident occured.
    latitude INT NOT NULL, # Latitude coordinate of the accident
    longitude INT NOT NULL # Longitude coordinate of the accident
    );
    
DROP TABLE IF EXISTS descriptions;
CREATE TABLE descriptions (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, # Accident ID number
    crash_configuration VARCHAR(255) NOT NULL, # How did the crash occur (ie. Rear End, Side Impact, Head-On, etc.)
    total_crashes INT NOT NULL, # Number of total crashes that occured within a single accident
    total_victims INT NOT NULL # Number of total victims harmed in the accident
    );
    
# There are 213,084 recorded accidents in the dataset.
# Confirming that each table has the same count.
SELECT COUNT(*)
FROM tags;

SELECT COUNT(*)
FROM times;

SELECT COUNT(*)
FROM locations;

SELECT COUNT(*)
FROM descriptions;

# Initial overview of each table
SELECT *
FROM tags
LIMIT 10;

SELECT *
FROM times
LIMIT 10;

SELECT *
FROM locations
LIMIT 10;

SELECT *
FROM descriptions
LIMIT 10;

/**
2: Locations Overview

Here I will do a preliminary analysis of the data.
Given the number of tags and times in particular, there is a significant amount of relationships that can be analyzed in this data.
For the purposes of this analysis, the focus will primarily be on the identifying trends at the neighborhood level within Vancouver
**/

# Q1: Which neighborhood had the most accidents overall?
SELECT neighborhood, COUNT(*) as total
FROM locations
GROUP BY neighborhood
ORDER BY total DESC;
# A1: Downtown had the most accidents with 30,516, which is unsurprising given the density of cars and people in the Downtown neighborhood
# Very common commute routes with Mount Pleasant (Cambie Street), Fairview (Granville Street), Renfrew-Collingwood (Grandview Hwy) and
# Kensington-Cedar Cottage (Kingsway) rounding out the Top 5.


# Q2: Which street has the most accidents overall?
SELECT street_name, COUNT(*) as total
FROM locations
GROUP BY street_name
ORDER BY total DESC;
# A2: Kingsway had the most accidents with 6099 reported
# However, streets in Vancouver going East/West are split and have East and West portions to them
# Broadway is one such example, with 5373 accidents for W Broadway and 3555 for E Broadway, even though it is one continuous road
# If these were added together, Broadway as a whole would have the most accidents with 8928 accidents

# Q3: Which street sub-section, encompassed by a single neighborhood, has the most accidents overall?
SELECT street_name, neighborhood, COUNT(*) as total
FROM locations
GROUP BY street_name, neighborhood
ORDER BY total DESC;
# A3: West Georgia in the Downtown neighborhood has the most accidents reported with 2941
# Grandview Hwy (Renfew), Kingsway (Kensington) and W Broadway (Fairview) are representative of the overall neighborhood totals as well.
# It is not immeidately apparent which roads would contribute to Mount Pleasant's high number of accidents, so we'll have a closer look.

# Q4: Which streets within the Mount Pleasant neighborhood have the most accidents?
SELECT street_name, neighborhood, COUNT(*) as total
FROM locations
WHERE neighborhood = 'Mount Pleasant'
GROUP BY street_name, neighborhood
ORDER BY total DESC;
# Main, E Broadway, Kingsway and E 12th is a complicated area of intersections with Kingsway running diagonally through each
# It would appear that the number of accidents is distributed across this cross section of streets more equally in order to
# contribute to a high total for the Mount Pleasant neighborhood

# Q5: Which intersection has the most accidents?
SELECT full_location, neighborhood, COUNT(*) as total
FROM locations
WHERE cross_street != ''
GROUP BY full_location, neighborhood
ORDER BY total DESC;
# A5: The Boundary/Grandview/Grandview Hwy Onramp has the most accidents with 1151.
# Boundary/Grandview is a major intersection that is on the border of Burnaby/Vancouver and the Onramp leads to Highway 1
# This would be a very high volume intersection, leading to the most accidents at an intersection in the city.
# Despite being the neighborhood with the most accidents, it seems there are very few intersections from downtown.  I'll have a closer look

# Q6: Which intersections Downtown have the most accidents?
SELECT full_location, neighborhood, COUNT(*) as total
FROM locations
WHERE cross_street != '' AND neighborhood = 'Downtown'
GROUP BY full_location, neighborhood
ORDER BY total DESC;
# A6: Main & Terminal has the most accidents Downtown with 675
# After that, it appears most of the accidents that occur at intersections are spread along the length of West Georgia street.
# Digging deeper, lets look specifically at intersections that are along West Georgia

# Q7: List the greatest number of accidents that happened along W Georgia in Downtown
SELECT full_location, neighborhood, COUNT(*) as total
FROM locations
WHERE cross_street != '' AND neighborhood = 'Downtown' AND full_location LIKE '%W GEORGIA ST%'
GROUP BY full_location, neighborhood
ORDER BY total DESC;
# A7: Denman/W Georgia is the intersection with the most accidents (459) along West Georgia St.
# This is the intersection that is the closest to the Lion's Gate Bridge which leads to/from West and North Vancouver.
# Using this, let's determine the total number of accidents that occured along W Georgia at an intersection

# Q8: Total number of accidents occured at an intersection along West Georgia
SELECT COUNT(total) as number_of_intersections, SUM(total) as total_number_of_accidents
FROM
(
SELECT full_location, COUNT(*) as total
FROM locations
WHERE cross_street != '' AND neighborhood = 'Downtown' AND full_location LIKE '%W GEORGIA ST%'
GROUP BY full_location
) AS g_inter_accidents
;
# There were 3387 accidents that occured across 22 intersections where West Georgia street was the primary OR cross street.
# This is approximately triple the number of accidents that occured at the intersection with the most accidents
# While the number of accidents is spread out across a longer stretch of road, this suggests the volume of traffic along
# West Georgia is a major source of accidents in Vancouver
# The last column to inspect in the Locations table is the Cross Street.  I suspect many cross streets will share results as the Full Location querries.

# Q9: Which cross street is responsible for the most accidents in Vancouver?
SELECT cross_street, COUNT(*) as total
FROM locations
GROUP BY cross_street
ORDER BY total DESC;
# A9: 71418 accidents did not have a cross street and therefore did not occur at an intersection.  This will be confirmed later when analyzing the Tags table
# The most accidents occured when Main street was the cross street.
# An interesting trend appears here where roads that are connected to bridges (Cambie, Granville, Oak, Fraser, Knight) are high on this list
# One cross street that is high on the list that does not follow this trend is Victoria Drive.  Let's have a closer look.

# Q10: List the full location of accidents where Victoria Drive was the cross street.
SELECT full_location, neighborhood, cross_street, COUNT(*) as total
FROM locations
WHERE cross_street = 'VICTORIA DR'
GROUP BY cross_street, full_location, neighborhood
ORDER BY total DESC;
# The most accidents occur on East 41st (517) and Kingsway (505) with Victoria Drive as the cross street.
# Kingsway has already been identified as the road with the most accidents, with this intersection being a major contributor
# East 41st and Victoria Dr was previously identified as the intersection with the 3rd most accidents
# Let's confirm which cross street of the intersection has the greater contibution to the number of accidents

# Q11: Total accidents contributed to the E 41st/Victoria intersection by Cross Street
SELECT full_location, neighborhood, cross_street, COUNT(*) as total
FROM locations
WHERE full_location LIKE '%VICTORIA DR%' AND full_location LIKE '%E 41ST AVE%'
GROUP BY cross_street, full_location, neighborhood
ORDER BY total DESC;
# There are 517 accidents at this intersection When Victoria Drive is the cross street, and 311 when E 41st Ave is the cross street
# This could be a result of a higher volumne of traffic traveling along E 41st compared to Victoria Drive
# Or maybe there are local factors that need to be investigated to understand this disparity.

/**
3: Using Descriptions to Identify Trends in Accidents Within Vancouver Neighborhoods

The descriptions table describes how an accident occured (Head On, Side Impact, etc) and the number of crashes and victims within each accident
Here, I will identify if there are any trends related to these descriptions within the neighborhoods of Vancouver
**/

# Q1: Explore the Descriptions Table using Group Bys for Victims, Crashes and Crash_configuation

SELECT total_victims, COUNT(*) as total
FROM descriptions
GROUP BY total_victims
ORDER BY total_victims;
# Most accidents, 167,600, do not involve any victims
# From there, it seems as though the total number of victims decreases in an exponential way

SELECT total_crashes, COUNT(*) as total
FROM descriptions
GROUP BY total_crashes
ORDER BY total_crashes;
# The mass majority of accidents only involve 1 crash (212,172), with just over 900 accidents involving more than 1 crash crash

SELECT crash_configuration, COUNT(*) as total
FROM descriptions
GROUP BY crash_configuration
ORDER BY total DESC;
# Rear Ends (46791) and Side Impacts (45985) occur the most
# However, there are a couple of categories (Undetermined, Conflicted) that do not have a specific description for how the accident occured

# Q2: Which neighborhood had the most victims
SELECT neighborhood, COUNT(*) as total_accidents, SUM(total_victims) as victim_total
FROM locations as l
INNER JOIN descriptions as d
	ON l.id = d.id
GROUP BY neighborhood
ORDER BY victim_total DESC;
# A1: Given the volume of traffic and number of total accidents, it is no surprise that Downtown has the highest number of victims from accidents with 7330
# However, the proportion of victims relative to the number of accidents does not seem to be nearly as high for the Downtown area

# Q3: Which neighborhood had the highest proportion of accidents that had at least 1 victim?
SELECT
	neighborhood,
    ROUND(AVG(IF(total_victims > 0, 1, 0))*100, 2) as with_victims_pct
FROM locations as l
INNER JOIN descriptions as d
	ON l.id = d.id
GROUP BY neighborhood
ORDER BY with_victims_pct DESC;
# A3: Here we see a much different picture as to the location of accidents that frequently have a victim
# Kensington-Cedar Cottage has the highest percentage of accidents with a victim at 28.63%
# Only 18.08% of accidents Downtown have a victim.
# With, Kensington-Cedar Cottage having the highest percentage here, I would like to see the breakdown of accidents in this neighborhood that had 0, 1, and 2 or more victims

# Q4: How many accidents in Kensington-Cedar Cottage had 0, 1, and 2 or more victims?
SELECT
	CASE
		WHEN total_victims = 0 THEN 'Property Only'
        WHEN total_victims = 1 THEN '1 Victim'
        ELSE '2 or More Victims'
        END as accident_type,
	COUNT(*) as total
FROM locations as l
INNER JOIN descriptions as d
	ON l.id = d.id
WHERE neighborhood = 'Kensington-Cedar Cottage'
GROUP BY accident_type;
# A5: Kensington-Cedar Cottage had 9370 accidents that were property damage only, 2568 that had 1 victim and 1190 that had two or more victims.
# Perhaps a better way to understand this would be as proportions of accidents in the neighbourhood.

# Q5: What is the percentage of accidents that had 0, 1, and 2 or more victims in Kensington-Cedar Cottage?
WITH kensington_victims AS
(
SELECT
	CASE
		WHEN total_victims = 0 THEN 'Property Only'
        WHEN total_victims = 1 THEN '1 Victim'
        ELSE '2 or More Victims'
        END as accident_type,
	COUNT(*) as total
FROM locations as l
INNER JOIN descriptions as d
	ON l.id = d.id
WHERE neighborhood = 'Kensington-Cedar Cottage'
GROUP BY accident_type
)

SELECT
	accident_type,
    total,
    SUM(total) OVER () as grand_total,
    ROUND(total/(SUM(total) OVER ())*100,2) as proportion
FROM kensington_victims;

# A5: Represented as proportions, we can see that 71.37% of accidents were property only, 19.56% of accidents had 1 victim and 9.06% of accidents had 2 or more victims
# Next I would like to dig deeper in the number of accidents that had more than one crash reported in the incident

# Q6: Which neighborhood had the highest percentage of multi-crash accidents?
SELECT
	neighborhood,
    SUM(IF(total_crashes > 1, 1, 0)) as multi_car_total,
    COUNT(*) as neighborhood_total,
    ROUND(AVG(IF(total_crashes > 1, 1, 0))*100, 2) as multi_car_pct
FROM locations as l
JOIN descriptions as d
		ON l.id = d.id
GROUP BY neighborhood
ORDER BY multi_car_pct DESC;
# A6: While even the highest percentage is relatively low (all less than 1%), Renfrew-Collingwood has the highest percentage of multi-car
# crashes at 0.72%.  The top 3 neighborhoods are the eastern-most neighborhoods in Vancouver, with Boundary Rd being a major throughfare
# Perhaps this can be analyzed further by looking at the Full Location of these accidents.

# Q7: Identify which locations had a high percentage of multi-car accidents.  Limiting to at locations that had at least 100 accidents with  at least 5 multi-crash accidents (avg 1 per year of data)
SELECT
	full_location,
	neighborhood,
    ROUND(AVG(IF(total_crashes > 1, 1, 0))*100, 2) as multi_car_pct,
    SUM(IF(total_crashes > 1, 1, 0)) as multi_car_total,
    COUNT(*) as total
FROM locations as l
JOIN descriptions as d
	ON l.id = d.id
GROUP BY full_location, neighborhood
HAVING total > 100 AND multi_car_total >= 1
ORDER BY multi_car_pct DESC;
# A7: Under this classification, the Cassiar Tunnel in the Hastings-Sunrise neighborhood has the greatest proportion of multi-crash accidents.
# The Boundary/Grandview Highway intersection, in addition to being the intersection with the most accidents, also has a relatively high proportion of multi-car accidents
# Revisiting crash configurations, I would like to see the type of configuration that has the highest average number of victims to understand which types of crashes are most dangerous

# Q8: What is the most frequent crash configuration for all accidents in Vancouver
SELECT
	crash_configuration,
    ROUND(AVG(total_victims),3) as avg_victims,
	COUNT(*) as total
FROM descriptions
GROUP BY crash_configuration
ORDER BY avg_victims DESC;
# A8: Multiple Impacts has the highest average number of victims at 0.551.  Rear End accidents are close behind at 0.548 victims per crash.  Head On Collisions average 0.479 victims per crash
# Multiple Impacts and Head On Collisions rank high on this list than they do for the total number of accidents.
# I would like to identify which neighborhoods has the highest average number of victims resulting from Head On and Multiple Collisions.

# Q9: Which neighborhood has the highest proportion of Multiple Impact and Head On Collisions
SELECT
	neighborhood,
    ROUND(AVG(total_victims),3) as avg_victims,
    COUNT(*) as total
FROM descriptions as d
JOIN locations as l
	ON l.id = d.id
WHERE crash_configuration = 'MULTIPLE IMPACRTS' OR crash_configuration = 'HEAD ON'
GROUP BY neighborhood
ORDER BY avg_victims DESC;
# A9: While the absolute number of accidents is relatively low, the South Cambie neighborhood has the highest average number of victims by far at 0.76 victims per accident
# I would like to identify what area of the neighborhood is causing this extreme outcome

# Q10: What locations in South Cambie have the highest number of victims as a result of Multiple Impacts or Head On Collisions?
SELECT
	full_location,
    ROUND(AVG(total_victims),3) as avg_victims,
    COUNT(*) as total
FROM descriptions as d
JOIN locations as l
	ON l.id = d.id
WHERE neighborhood = 'South Cambie' AND (crash_configuration = 'MULTIPLE IMPACTS' OR crash_configuration = 'HEAD ON')
GROUP BY full_location
ORDER BY avg_victims DESC;
# A10: Given the low total of accidents in this neighborhood overall, the high average of victims per crash could be an unfortunate result of low sample size for the area.
# One intersection does stand out with a higher number of this type of accident: Cambie St & W 41st Ave (8 accidents).  This intersection is located by Oakridge mall and would be a high volume intersection
# It does not appear any specific location in South Cambie is resulting in the higher average number of victims as a result of Multiple or Head On Collisions

/**
4: Exploring the Times of Accidents for Vancouver Neighborhoods

The descriptions table describes when an accident occured, including the time of day, day of the week and month of the year.
The data did NOT include the day of the month (ie. January 17th) but should still enable some analysis that could identify
if accidents occur in a cyclical nature during the day, week or year.

First, we will identify trends for when accidents occur during the day and how that differs between neighborhoods
**/

# Q1: What time of day does the most accidents occur?
SELECT
	time_of_day,
	COUNT(*) as total
FROM times
GROUP BY time_of_day
ORDER BY total desc;
# A1: It is no surprise that the work day (9:00 - 17:59) comprises most of the accidents during the day, with the number of accidents
# peaking between 15:00-17:59 (54904).
# I suspect that the Downtown neighborhood will have the most accidents during this timeframe, but it is worth confirming

# Q2: Which neighborhood has the most accidents during the peak time of day for the most accidents (15:00-17:59)
SELECT
	neighborhood,
    COUNT(*) as total
FROM times as t
JOIN locations as l
	ON t.id = l.id
WHERE time_of_day = '15:00-17:59'
GROUP BY neighborhood
ORDER BY total DESC;
# A2: As suspected, Downtown has the most accidents in this time duration, but there may be other neighborhoods that have a higher proportion
# of accidents during this time frame given the total number of accidents.

# Q3: Which neighborhood has the highest proportion of their accidents during the 15:00-17:59 time frame?
SELECT
	neighborhood,
	SUM(IF(time_of_day = '15:00-17:59', 1, 0)) as total_at_time,
    COUNT(*) as grand_total,
	ROUND(AVG(IF(time_of_day = '15:00-17:59', 1, 0))*100, 2) as proportion
FROM times as t
JOIN locations as l
	ON t.id = l.id
GROUP BY neighborhood
ORDER BY proportion DESC;
# A3: This provides a much different picture of accidents during this time frame.  While Downtown had the highest number of accidents, it was
# the second lowest in its proportion of accidents during this time frame.  Stanley Park (32.76%) had the highest proportion by far, but this 
# could be a result of low sampling, since Stanley Park had the lowest number of accidents by far.
# West Point Grey has the second highest proportion of accidents occuring at this time.  Lets see where these accidents are occuring.

# Q4: Locations in West Point Grey with the highest proportion of accidents between 15:00-17:59 with at least 10 accidents reported.
SELECT
	full_location,
	SUM(IF(time_of_day = '15:00-17:59', 1, 0)) as total_at_time,
    COUNT(*) as grand_total,
	ROUND(AVG(IF(time_of_day = '15:00-17:59', 1, 0))*100, 2) as proportion
FROM times as t
JOIN locations as l
	ON t.id = l.id
WHERE neighborhood = 'West Point Grey'
GROUP BY full_location
HAVING grand_total > 10
ORDER BY proportion DESC;
# A4: The Crown & West 16th intersection, as well as the Dunbar Diversion intersection both had 50% of their accidents occur between 15:00-17:59.
# Crown & West 16th had more accidents occur during this time frame (18 vs 6) which is particularly troublesome because an elementary school
# (Jules Quesnel) and a high school (Lord Byng) are located at this intersection.  It would appear that a significant number of accidents
# are happening during pick-up when school ends at this intersection.
# Next we will analyze what day of the week accidents are occuring

# Q5: Which day of the week has the most accidents?
SELECT
	day_of_week,
	COUNT(*) as total
FROM times
GROUP BY day_of_week
ORDER BY total DESC;
# A5: Week days have more accidents than weekends, but the number of accidents seem to increase during the course of the week
# peaking on Fridays (36,146 accidents total)
# I am interested to see if there is a difference between the number of accidents that occur in a neighborhood on a week day
# vs a week end

# Q6: What is the proportion of accidents that happen on during the work week vs during the weekend for each neighborhood?
SELECT
	neighborhood,
    ROUND(AVG(IF(day_of_week IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'), 1, 0))*100, 2) as week_day_prop,
    ROUND(AVG(IF(day_of_week IN ('SATURDAY', 'SUNDAY'), 1, 0))*100, 2) as week_end_prop
FROM times as t
JOIN locations as l
	ON t.id = l.id
GROUP BY neighborhood
ORDER BY week_day_prop DESC;
# A6: There are some very distinct differences in these proportions when looking at each neighborhood.
# Shaughnessy (82.23%) and Fairview (80.93%) are the only neighborhoods where more than 80% of their accidents occur on the weekend
# Stanley Park has by far the highest proportion of accidents on the weekend (42.53%).  This is likely a result of it being more of a tourist
# destination than other neighborhoods.

# Q7: How does the percentage of accidents per day in Shaughnessy compare to the overall percentage of accidents per day?
WITH overall AS
(
SELECT
	day_of_week,
    COUNT(*)/SUM(COUNT(*)) OVER()*100 as overall_pct_accidents_per_day
FROM locations
JOIN times ON
	times.id = locations.id
WHERE neighborhood != 'Shaughnessy'
GROUP BY day_of_week
ORDER BY day_of_week
),

shaughnessy AS
(
SELECT
	day_of_week,
    COUNT(*)/SUM(COUNT(*)) OVER()*100 as shaughnessy_pct_accidents_per_day
FROM locations
JOIN times ON
	times.id = locations.id
WHERE neighborhood = 'Shaughnessy'
GROUP BY day_of_week
ORDER BY day_of_week
)

SELECT
	o.day_of_week,
    shaughnessy_pct_accidents_per_day,
    overall_pct_accidents_per_day,
    ROUND((shaughnessy_pct_accidents_per_day - overall_pct_accidents_per_day)/overall_pct_accidents_per_day*100, 2) as pct_difference
FROM overall as o
JOIN shaughnessy as s
	ON o.day_of_week = s.day_of_week
ORDER BY pct_difference DESC;

# A7: Shaughnessy appears to have a less distinct peak of accidents during the week compared to other neighborhoods.  While Friday still
# has the highest proportion of accidents for Shaughnessy (17.32%), Wednesdays and Thursdays are also relatively close to this peak compared
# to the totals of other neighborhoods.  For instance, Shaughnessy had a 12.52% higher proportion of accidents on Wednesdays compared to
# other neighborhoods.  Conversely, Shaughnessy had a significantly lower proportion of accidents on the weekend, in particular on Saturday
# Where the proportion of accidents was 28.75% lower than other neighborhoods.

# Last we will look at any differences for accidents by month by the neighborhood

# Q8: What were the total number of accidents for each month?
SELECT
	month_of_year,
    COUNT(*) as total
FROM times
GROUP BY month_of_year
ORDER BY STR_TO_DATE(CONCAT('0001', month_of_year, '01'), '%Y %M %d');
# A8: This may be a more difficult to interpret.  While it seems that March and April have significantly lower totals than other months,
# this could be a result of the peak of the Pandemic being March/April of 2020.
# Considering this data ends at the end of the year in 2021, perhaps it would be insightful to see the proportion of accidents
# that occured before and after the start of the pandemic to see if trends have changed within the neighborhoods

# Q9: How did the monthly accident totals change since the start of the pandemic for each neighborhood?
WITH monthly_averages AS
(
SELECT
	neighborhood,
	SUM(IF(((month_of_year != 'JANUARY' OR month_of_year != 'FEBRUARY') AND year_ = 2020) OR year_ = 2021, 1, 0))/22 as covid_count, # Divided by number of months post-covid in the data
    SUM(IF(((month_of_year = 'JANUARY' OR month_of_year = 'FEBRUARY' ) AND year_ = 2020) OR year_ < 2020, 1, 0))/38 as pre_covid_count # Divided by number of months pre-covid in the data
FROM locations as l
JOIN times as t
	ON l.id = t.id
GROUP BY neighborhood
)
SELECT
	neighborhood,
    covid_count,
    pre_covid_count,
    covid_count - pre_covid_count as covid_difference,
    ROUND((covid_count - pre_covid_count)/pre_covid_count*100, 2) as pct_decrease
FROM
	monthly_averages
ORDER BY pct_decrease DESC;
# A9: While every neighborhood had a decrease in accidents per month since the start of the pandemic, there was a wide variety in how much accidents decreased by.
# Stanley Park had the biggest decrease by far (45.19% fewer accidents per month) followed by Sotuh Cambie (33.93%) and Downtown (32.43%)
# Victoria-Fraserview had the smallest decrease (12.89%) followed by West Point Grey (15.39%) and the West End (16.94%)


/**
4: Exploring the Tags for the Accidents in Vancouver Neighborhoods

There are numerous 'Tags' for the accidents in the dataset.  Most of them are 'Yes' or 'No', with the exception of crash_severity which is still a binary tag showing whether there was a
accident was a 'CASUALTY CRASH' or if there was just 'PROPERTY DAMAGE'

Here, we will explore what type of accidents are more prevelant in some neighborhoods than others
**/

# Q1: Which neighborhood has the most accidents where an animal was involved?
SELECT 
	neighborhood,
    COUNT(*) as neighborhood_total,
    SUM(COUNT(*)) OVER() as grand_total
FROM tags
JOIN locations
	ON tags.id = locations.id
WHERE animal = 'Yes'
GROUP BY neighborhood
ORDER BY neighborhood_total DESC;
# A1: Overall, there are very few accidents that involve animals, with just 146 over the course of the entire dataset of 200K+
# Renfrew-Collingwood had the most with 13 accidents, while Riley Park, Mount Pleasant and Kensington-Cedar Cottate all had 12.
# These are primarily residential areas of Vancouver, but it is hard to identify a specific trend given the small sample size

# Q2: Which neighborhood has the most accidents involving a cyclist?
SELECT 
	neighborhood,
    COUNT(*) as neighborhood_total,
    SUM(COUNT(*)) OVER() as grand_total,
    ROUND(COUNT(*)/SUM(COUNT(*)) OVER()*100,2) as pct_total
FROM tags
JOIN locations
	ON tags.id = locations.id
WHERE cyclist = 'Yes'
GROUP BY neighborhood
ORDER BY neighborhood_total DESC;
# A2: Downtown has the highest number of accidents with a cyclist, comprising 20.88% of all accidents with a cyclist in Vancouver
# This is actually a HIGHER proportion of accidents compared to the overall total of Downtown accidents, intimating that a high number of residents
# commute to Downtown on their bikes leading to an increased incidence in accidents involving a cyclist Downtown

# Q3: Which neighborhood has the most accidents that had a casualty?
SELECT 
	neighborhood,
    COUNT(*) as neighborhood_total,
    SUM(COUNT(*)) OVER() as grand_total,
    ROUND(COUNT(*)/SUM(COUNT(*)) OVER()*100,2) as pct_total
FROM tags
JOIN locations
	ON tags.id = locations.id
WHERE crash_severity = 'CASUALTY CRASH'
GROUP BY neighborhood
ORDER BY neighborhood_total DESC;
# A3: While Downtown had the most accidents, Renfrew-Collingwood, Kensington-Cedar Cottage and Mount Pleasant all had more than 3500 accidents with a casualty
# However, this may highlight the fact that there may be some redundancy in the dataset.  If a accident had more than 0 victims (from the descriptions table), it could
# be considered a Casualty Crash.  I will see if there is any accidents that had more than 0 victims but was classified as Property Damage Only

# Q4: Identify accidents that had more than 0 victims and was classified as Property Damage Only.
SELECT *
FROM tags
JOIN descriptions
	ON tags.id = descriptions.id
WHERE total_victims > 0 AND crash_severity = 'PROPERTY DAMAGE';
# A4: This returns an empty list.  While this shows that some of the data could be considered redundant, it also ensures the data quality of the crash_severity tag.
# We have already explored the total victims from accidents, so I will explore other tags in this dataset here.

# Q5: Which neighborhood has the greatest incidence of accidents involving heavy vehicles?
SELECT 
	neighborhood,
    COUNT(*) as neighborhood_total,
    SUM(COUNT(*)) OVER() as grand_total,
    ROUND(COUNT(*)/SUM(COUNT(*)) OVER()*100,2) as pct_total
FROM tags
JOIN locations
	ON tags.id = locations.id
WHERE heavy_vehicle = 'Yes'
GROUP BY neighborhood
ORDER BY neighborhood_total DESC;
# A5: Downtown again has the most accidents, with 2093 accidents out of 13391 total accidents involving a heavy_vehicle.
# However, I would like to see which neighborhood has a higher incidence of heavy vehicle accidents compared to their overall total

# Q6: Which neighborhood has the largest difference between their total proportion of accidents and the proportion of accidents with a heavy vehicle?
WITH hv_accidents AS
(
SELECT 
	neighborhood,
    COUNT(*)/SUM(COUNT(*)) OVER()*100 as pct_total
FROM tags
JOIN locations
	ON tags.id = locations.id
WHERE heavy_vehicle = 'Yes'
GROUP BY neighborhood
),
overall_accidents AS
(
SELECT
	neighborhood,
	COUNT(*)/SUM(COUNT(*)) OVER()*100 as overall_pct
FROM locations
GROUP BY neighborhood
)

SELECT
	overall_accidents.neighborhood,
	pct_total,
    overall_pct,
    pct_total-overall_pct as pct_diff
FROM overall_accidents
JOIN hv_accidents
	ON overall_accidents.neighborhood = hv_accidents.neighborhood
ORDER BY pct_diff DESC;
# A6: Strathcona had the greatest increase in percentage of accidents when comparing accidents involving heavy vehicles compared to the overall total
# 3.71% of all accidents in Vancouver were in Strathcona, whereas 5.87% of accidents that had a heavy vehicle were in Strathcona, with a difference of 2.16%
# Strathcona is a highly industrialized area of Vancouver which could explain this increase
# Interestingly, while Mount Pleasant was third on the total number of accidents involving a heavy vehicle, the proportion of heavy vehicle accidents was much lower
# than the porportion of total accidents that occured in Mount Pleasant (a 2.49% decrease).
# Given the increased proportion of heavy vehicle accidents in Strathcona, I would like to explore this further

# Q7: What time of day are heavy vehicle accidents occuring in Strathcona?
SELECT
	time_of_day,
	COUNT(*) as total
FROM locations
INNER JOIN tags
	ON tags.id = locations.id
INNER JOIN times
	ON times.id = locations.id
WHERE neighborhood = 'Strathcona' AND heavy_vehicle = 'Yes'
GROUP BY time_of_day
ORDER BY time_of_day ASC;
# A7: It appears that most of the accidents occur in the middle of the work day from 9am to 3pm, but more frequently during the afternoon with 262 heavy vehicle accidents occuring
# between noon and 3pm.  Considering that Strathcona is heavily industrialized, I'm curious as to what time of day may have a proportionally higher number of heavy vehicle accidents
# When compared to other neighborhoods.

WITH not_strathcona AS
(
SELECT
	time_of_day,
	COUNT(*)/SUM(COUNT(*)) OVER() as total_pct
FROM locations
INNER JOIN tags
	ON tags.id = locations.id
INNER JOIN times
	ON times.id = locations.id
WHERE neighborhood != 'Strathcona' AND heavy_vehicle = 'Yes'
GROUP BY time_of_day
),
strathcona AS
(
SELECT
	time_of_day,
	COUNT(*)/SUM(COUNT(*)) OVER() as strath_pct
FROM locations
INNER JOIN tags
	ON tags.id = locations.id
INNER JOIN times
	ON times.id = locations.id
WHERE neighborhood = 'Strathcona' AND heavy_vehicle = 'Yes'
GROUP BY time_of_day
)
SELECT
	strathcona.time_of_day,
	ROUND(strath_pct*100, 2) as strathcona_percentage,
	ROUND(total_pct*100, 2) as total_percentage,
    ROUND((strath_pct/total_pct - 1)*100, 2) as percent_diff
FROM strathcona
LEFT JOIN not_strathcona
	ON strathcona.time_of_day = not_strathcona.time_of_day
ORDER BY time_of_day ASC;

# A8: Compared to the other Vancouver neighborhoods, there appears to be a much greater incidence of heavy vehicle accidents in Strathcona
# at night (52.17% increase from midnight to 3am, 10.92% increase from 9pm-midnight) as well as early afternoon (17.98% increase from noon to 3pm)
# Considering that the highest volume of accidents also occured from noon-3pm, this would suggest that there is a very significant increase in the volume of
# traffic during this time frame, resulting in a significant risk for heavy vehicle accidents

# For my last query, utilizing the crash_severity tag, I would like to see where the highest number of victims per accident are occuring
# To do this, I will identify on accidents that are classified as a 'CASUALTY CRASH' and take the overall average number of victims in these crashes
# Then compare the average number of victims per accident within each neighborhood against the overall average to see which neighborhoods have accidents
# that result in the greatest number of victims

# Q9: Which neighborhood had the highest average number of victims of accidents that had a casualty?
WITH n_summary AS
(
SELECT
	l.neighborhood,
	SUM(d.total_victims) as victim_total,
    SUM(d.total_victims)/COUNT(*) as victims_per_accident
FROM locations AS l
INNER JOIN descriptions AS d ON
	l.id = d.id
INNER JOIN tags AS t ON
	l.id = t.id
WHERE t.crash_severity = 'CASUALTY CRASH'
GROUP BY neighborhood
ORDER BY victims_per_accident DESC
)
    
SELECT
	neighborhood,
    victims_per_accident,
    AVG(victims_per_accident) OVER () as overall_victim_average,
    ROUND((((victims_per_accident/AVG(victims_per_accident) OVER ()) - 1)*100),2) as percent_diff
FROM n_summary
ORDER BY percent_diff DESC
LIMIT 10;

# A9: Stanley Park had the highest number of victims per accident, 12.23% higher than the average.
# Oakridge (7.43%) and Sunset (6.01%) are the only other neighborhoods that had at least 5% more victims per accident than the overall average

/*
CONCLUSION

While there is much to get into this data, much of the information could be greatly enhanced by some better contextual information.
For instance, it is unsurprising that Downtown has the greatest total numbers given the volume of traffic.  To highlight areas of increased risk,
comparing the proportion of accidents between each neighborhood, but having data on the overall volume of traffic would provide much greater insight.

As well, it appears that this data includes accidents that were reported to ICBC but NOT reported to the police.  High risk factors for accidents,
such as speeding and impaired driving, was not available in this dataset.

While the goal of this project was to explore the data generally to identify some key trends, these queries could be shaped in a way that could provide
a consistent 'neighborhood report' for each neighborhood in Vancouver that could identify times/locations that could be higher risk for accidents in general
and where certain types of accidents are more likely to occur.  With this information, preventative measures could be taken at a more local level in order to prevent
accidents in the future.
*/



    