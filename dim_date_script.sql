
-- '20210201' min date in trip table
DECLARE @StartDate DATE = '19400101', @NumberOfYears INT = 200;


CREATE TABLE #dimdate
(
  [date]       DATE,  
  [day]        tinyint,
  [month]      tinyint,
  FirstOfMonth date,
  [MonthName]  varchar(12),
  [week]       tinyint,
  [ISOweek]    tinyint,
  [DayOfWeek]  tinyint,
  [quarter]    tinyint,
  [year]       smallint,
  FirstOfYear  date,
  Style112     char(8),
  Style101     char(10)
);


SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);



INSERT #dimdate([date]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn-1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    ORDER BY s1.[object_id]
  ) AS x
) AS y;


UPDATE #DimDate 
set 
  [day]        = DATEPART(DAY,      [date]),
  [month]      = DATEPART(MONTH,    [date]),
  FirstOfMonth = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
  [MonthName]  = DATENAME(MONTH,    [date]),
  [week]       = DATEPART(WEEK,     [date]),
  [ISOweek]    = DATEPART(ISO_WEEK, [date]),
  [DayOfWeek]  = DATEPART(WEEKDAY,  [date]),
  [quarter]    = DATEPART(QUARTER,  [date]),
  [year]       = DATEPART(YEAR,     [date]),
  FirstOfYear  = CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
  Style112     = CONVERT(CHAR(8),   [date], 112),
  Style101     = CONVERT(CHAR(10),  [date], 101)
;


CREATE TABLE Calendar
WITH
(
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT
  DateKey       = CONVERT(INT, Style112),
  [Date]        = [date],
  [Day]         = CONVERT(TINYINT, [day]),
  DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
                  CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
	              WHEN '3' THEN 'rd' ELSE 'th' END END),
  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
                  (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
                  (PARTITION BY [year], [month] ORDER BY [week])),
  WeekOfYear    = CONVERT(TINYINT, [week]),
  ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
  [Month]       = CONVERT(TINYINT, [month]),
  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
  [Quarter]     = CONVERT(TINYINT, [quarter]),
  QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                  WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
  [Year]        = [year],
  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
  MonthYear     = CONVERT(CHAR(8), LEFT([MonthName], 3) + ' ' + LEFT(Style112, 4)),
  FirstDayOfMonth     = FirstOfMonth,
  LastDayOfMonth      = MAX([date]) OVER (PARTITION BY [year], [month]),
  FirstDayOfQuarter   = MIN([date]) OVER (PARTITION BY [year], [quarter]),
  LastDayOfQuarter    = MAX([date]) OVER (PARTITION BY [year], [quarter]),
  FirstDayOfYear      = FirstOfYear,
  LastDayOfYear       = MAX([date]) OVER (PARTITION BY [year]),
  FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
  FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
FROM #dimdate
;

DROP Table #dimdate;


-- Sample select to verify data
SELECT TOP 100 * FROM Calendar;