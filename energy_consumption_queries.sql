CREATE DATABASE energy_consumption_analysis;
USE energy_consumption_analysis;

CREATE TABLE energy_data (
    property_name TEXT,
    year_ending DATE,
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    borough VARCHAR(50),
    property_type VARCHAR(100),
    largest_property_type VARCHAR(100),
    gross_floor_area DOUBLE,
    year_built INT,
    number_of_buildings INT,
    occupancy INT,
    energy_star_score DOUBLE,
    site_eui DOUBLE,
    weather_normalized_site_eui DOUBLE,
    source_eui DOUBLE,
    site_energy_use DOUBLE,
    natural_gas_use DOUBLE,
    electricity_use DOUBLE,
    total_ghg DOUBLE,
    direct_ghg DOUBLE,
    indirect_ghg DOUBLE,
    latitude DOUBLE,
    longitude DOUBLE
);

SHOW TABLES;

SHOW VARIABLES LIKE 'local_infile';
ALTER TABLE energy_data
RENAME COLUMN `Property Name` TO property_name,
RENAME COLUMN `Year Ending` TO year_ending,
RENAME COLUMN `Address 1` TO address,
RENAME COLUMN `City` TO city,
RENAME COLUMN `Postal Code` TO postal_code,
RENAME COLUMN `Borough` TO borough,
RENAME COLUMN `Primary Property Type - Self Selected` TO property_type,
RENAME COLUMN `Largest Property Use Type` TO largest_property_type,
RENAME COLUMN `Largest Property Use Type - Gross Floor Area (ft²)` TO gross_floor_area,
RENAME COLUMN `Year Built` TO year_built,
RENAME COLUMN `Number of Buildings` TO number_of_buildings,
RENAME COLUMN `Occupancy` TO occupancy,
RENAME COLUMN `ENERGY STAR Score` TO energy_star_score,
RENAME COLUMN `Site EUI (kBtu/ft²)` TO site_eui,
RENAME COLUMN `Weather Normalized Site EUI (kBtu/ft²)` TO weather_normalized_site_eui,
RENAME COLUMN `Source EUI (kBtu/ft²)` TO source_eui,
RENAME COLUMN `Site Energy Use (kBtu)` TO site_energy_use,
RENAME COLUMN `Natural Gas Use (kBtu)` TO natural_gas_use,
RENAME COLUMN `Electricity Use - Grid Purchase (kWh)` TO electricity_use,
RENAME COLUMN `Total GHG Emissions (Metric Tons CO2e)` TO total_ghg,
RENAME COLUMN `Direct GHG Emissions (Metric Tons CO2e)` TO direct_ghg,
RENAME COLUMN `Indirect GHG Emissions (Metric Tons CO2e)` TO indirect_ghg,
RENAME COLUMN `Latitude` TO latitude,
RENAME COLUMN `Longitude` TO longitude;


-- 1:
SELECT COUNT(*) AS total_properties
FROM energy_data;

-- 2
SELECT COUNT(DISTINCT borough) AS total_boroughs
FROM energy_data;

-- 3
SELECT DISTINCT borough
FROM energy_data
ORDER BY borough;

-- 4
SELECT COUNT(DISTINCT property_type) AS total_property_types
FROM energy_data;

-- 5
SELECT
    property_type,
    COUNT(*) AS total_buildings
FROM energy_data
GROUP BY property_type
ORDER BY total_buildings DESC
LIMIT 10;

-- 6
SELECT
    property_name,
    borough,
    property_type,
    site_energy_use
FROM energy_data
ORDER BY site_energy_use DESC
LIMIT 10;

-- 7
SELECT
    borough,
    ROUND(AVG(site_energy_use), 2) AS avg_site_energy_use
FROM energy_data
GROUP BY borough
ORDER BY avg_site_energy_use DESC;

-- 8
SELECT
    property_type,
    ROUND(AVG(site_energy_use), 2) AS avg_site_energy_use
FROM energy_data
GROUP BY property_type
ORDER BY avg_site_energy_use DESC
LIMIT 10;

-- 9
SELECT
    property_name,
    borough,
    property_type,
    electricity_use
FROM energy_data
ORDER BY electricity_use DESC
LIMIT 10;

-- 10
SELECT
    property_name,
    borough,
    property_type,
    natural_gas_use
FROM energy_data
ORDER BY natural_gas_use DESC
LIMIT 10;

-- 11
SELECT
    property_name,
    borough,
    property_type,
    source_eui
FROM energy_data
ORDER BY source_eui DESC
LIMIT 10;

-- 12
SELECT
    property_name,
    borough,
    property_type,
    total_ghg
FROM energy_data
ORDER BY total_ghg DESC
LIMIT 10;

-- 13
SELECT
    borough,
    ROUND(AVG(total_ghg),2) AS avg_total_ghg
FROM energy_data
GROUP BY borough
ORDER BY avg_total_ghg DESC;

-- 14
SELECT
    property_type,
    ROUND(AVG(energy_star_score),2) AS avg_energy_star_score
FROM energy_data
WHERE energy_star_score IS NOT NULL
GROUP BY property_type
ORDER BY avg_energy_star_score DESC;

-- 15
SELECT
    property_name,
    borough,
    property_type,
    energy_star_score
FROM energy_data
WHERE energy_star_score IS NOT NULL
ORDER BY energy_star_score DESC
LIMIT 10;

-- 16
SELECT
    ROUND(SUM(direct_ghg),2) AS total_direct_ghg,
    ROUND(SUM(indirect_ghg),2) AS total_indirect_ghg
FROM energy_data;

-- 17
SELECT
    property_name,
    borough,
    property_type,
    site_energy_use
FROM energy_data
WHERE site_energy_use >
(
    SELECT AVG(site_energy_use)
    FROM energy_data
)
ORDER BY site_energy_use DESC;

-- 18
SELECT
    property_name,
    property_type,
    energy_star_score,
    CASE
        WHEN energy_star_score >= 85 THEN 'Excellent'
        WHEN energy_star_score >= 70 THEN 'Good'
        WHEN energy_star_score >= 50 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS efficiency_category
FROM energy_data
WHERE energy_star_score IS NOT NULL;

-- 19
SELECT
    property_name,
    borough,
    site_energy_use,
    RANK() OVER (ORDER BY site_energy_use DESC) AS energy_rank
FROM energy_data;

-- 20
SELECT
    property_name,
    borough,
    site_energy_use
FROM
(
    SELECT
        property_name,
        borough,
        site_energy_use,
        ROW_NUMBER() OVER
        (
            PARTITION BY borough
            ORDER BY site_energy_use DESC
        ) AS rn
    FROM energy_data
) ranked
WHERE rn = 1;

-- 21
WITH property_energy AS
(
    SELECT
        property_type,
        SUM(site_energy_use) AS total_energy
    FROM energy_data
    GROUP BY property_type
)

SELECT
    property_type,
    total_energy,
    ROUND(
        (total_energy /
        (SELECT SUM(site_energy_use) FROM energy_data)) * 100,
        2
    ) AS percentage_contribution
FROM property_energy
ORDER BY percentage_contribution DESC;

