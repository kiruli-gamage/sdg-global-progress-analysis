-- =========================================
-- 0. DROP TABLES IF THEY EXIST (in proper order)
-- =========================================
IF OBJECT_ID('dbo.SDG_Data', 'U') IS NOT NULL DROP TABLE dbo.SDG_Data;
GO
IF OBJECT_ID('dbo.Indicators', 'U') IS NOT NULL DROP TABLE dbo.Indicators;
GO
IF OBJECT_ID('dbo.Countries', 'U') IS NOT NULL DROP TABLE dbo.Countries;
GO

-- =========================================
-- 1. CREATE COUNTRIES TABLE
-- =========================================
CREATE TABLE dbo.Countries (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(MAX)
);
GO

-- =========================================
-- 2. CREATE INDICATORS TABLE
-- =========================================
CREATE TABLE dbo.Indicators (
    IndicatorID INT IDENTITY(1,1) PRIMARY KEY,
    Goal INT,
    Target VARCHAR(MAX),
    IndicatorCode VARCHAR(MAX),
    SeriesCode VARCHAR(MAX),
    SeriesDescription VARCHAR(MAX)
);
GO

-- =========================================
-- 3. CREATE SDG_DATA TABLE
-- =========================================
CREATE TABLE dbo.SDG_Data (
    DataID INT IDENTITY(1,1) PRIMARY KEY,
    IndicatorID INT,
    CountryID INT,
    TimePeriod INT,
    Value FLOAT,
    Time_Detail VARCHAR(MAX),
    Units VARCHAR(MAX),
    FOREIGN KEY (IndicatorID) REFERENCES dbo.Indicators(IndicatorID),
    FOREIGN KEY (CountryID) REFERENCES dbo.Countries(CountryID)
);
GO

-- =========================================
-- 4. INSERT COUNTRIES
-- =========================================
INSERT INTO dbo.Countries (CountryID, CountryName)
SELECT CountryID, MIN(CountryName) AS CountryName
FROM (
    SELECT CAST(GeoAreaCode AS INT) AS CountryID, GeoAreaName AS CountryName FROM Goal1
    UNION ALL
    SELECT CAST(GeoAreaCode AS INT), GeoAreaName FROM Goal4
    UNION ALL
    SELECT CAST(GeoAreaCode AS INT), GeoAreaName FROM Goal7
) AS AllCountries
GROUP BY CountryID;
GO

-- =========================================
-- 5. INSERT INDICATORS
-- =========================================
INSERT INTO dbo.Indicators (Goal, Target, IndicatorCode, SeriesCode, SeriesDescription)
SELECT DISTINCT
    Goal,
    Target,
    Indicator,
    SeriesCode,
    SeriesDescription
FROM Goal1;
GO

INSERT INTO dbo.Indicators (Goal, Target, IndicatorCode, SeriesCode, SeriesDescription)
SELECT DISTINCT
    Goal,
    Target,
    Indicator,
    SeriesCode,
    SeriesDescription
FROM Goal4;
GO

INSERT INTO dbo.Indicators (Goal, Target, IndicatorCode, SeriesCode, SeriesDescription)
SELECT DISTINCT
    Goal,
    Target,
    Indicator,
    SeriesCode,
    SeriesDescription
FROM Goal7;
GO

-- =========================================
-- 6. INSERT SDG_DATA (GOAL1)
-- =========================================
INSERT INTO dbo.SDG_Data (IndicatorID, CountryID, TimePeriod, Value, Time_Detail, Units)
SELECT 
    i.IndicatorID,
    CAST(g.GeoAreaCode AS INT),
    g.TimePeriod,
    TRY_CAST(g.Value AS FLOAT) AS Value, -- Safely convert to float, NULL if not numeric
    g.Time_Detail,
    g.Units
FROM Goal1 g
JOIN dbo.Indicators i
    ON i.SeriesCode = g.SeriesCode
   AND i.IndicatorCode = g.Indicator;
GO

-- =========================================
-- 7. INSERT SDG_DATA (GOAL4)
-- =========================================
INSERT INTO dbo.SDG_Data (IndicatorID, CountryID, TimePeriod, Value, Time_Detail, Units)
SELECT 
    i.IndicatorID,
    CAST(g.GeoAreaCode AS INT),
    g.TimePeriod,
    TRY_CAST(g.Value AS FLOAT) AS Value,
    g.Time_Detail,
    g.Units
FROM Goal4 g
JOIN dbo.Indicators i
    ON i.SeriesCode = g.SeriesCode
   AND i.IndicatorCode = g.Indicator;
GO

-- =========================================
-- 8. INSERT SDG_DATA (GOAL7)
-- =========================================
INSERT INTO dbo.SDG_Data (IndicatorID, CountryID, TimePeriod, Value, Time_Detail, Units)
SELECT 
    i.IndicatorID,
    CAST(g.GeoAreaCode AS INT),
    g.TimePeriod,
    TRY_CAST(g.Value AS FLOAT) AS Value,
    g.Time_Detail,
    g.Units
FROM Goal7 g
JOIN dbo.Indicators i
    ON i.SeriesCode = g.SeriesCode
   AND i.IndicatorCode = g.Indicator;
GO
