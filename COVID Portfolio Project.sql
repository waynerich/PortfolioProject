/*
https://www.coursera.org/articles/data-exploration
Data Exploration is considered as an important first step in data analysis as:
	it allows to perform an initial evaluation of the data's structures and underlying patterns
	it helps understand the different types of data involved such as what type of data is right to answer questions
	it can better inform data analysis and more accurately represent the data

This Data Exploration project on COVID dataset is guided by Alex Freberg: https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/COVID%20Portfolio%20Project%20-%20Data%20Exploration.sql
Dataset source: https://ourworldindata.org/covid-deaths
*/



/*
	This dataset focuses on location attribute to derive insights from such as:
		
	Date range is from 2020-01-01 to 2021-04-30
	In it's raw form, `location` values are grouped according to the `continent` it belongs
	However there are `continent` values under location attribute that are grouped as NULL in the continent attribute;
*/
SELECT DISTINCT(location)
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL

/*
	Hence the clause --WHERE continent IS NOT NULL; to exclude `continent` values in the location attribute to avoid skewed results and maintain consistency
*/
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


/*
	What is the likelihood/percentage of dying if a person gets contracted with COVID according to country?

	The query below returns skewed results due to total_deaths attribute being an nvarchar data type
*/
SELECT location, MAX(total_cases) totalCasesPerCountry, MAX(total_deaths) totalDeathsPerCountry
, (MAX(total_deaths) / MAX(total_cases) * 100) percentOfDying
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location

/*
	Hence by converting data type from nvarchar to int would give a more accurate result
*/
SELECT location, MAX(total_cases) totalCasesPerCountry, MAX(CONVERT(int, total_deaths)) totalDeathsPerCountry
, (MAX(CONVERT(int, total_deaths)) / MAX(total_cases) * 100) percentOfDying
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location


/*
	What is the percentage of population got infected with COVID per country?
*/
SELECT location, population, MAX(total_cases) totalCasesPerCountry, ((MAX(total_cases) / population) * 100) percentOfInfection
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY location


/*
	Which country has the highest infection rate?
*/
SELECT TOP 1 location, population, MAX(total_cases) totalCasesPerCountry, MAX((total_cases / population) * 100) percentOfInfection
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY percentOfInfection DESC


/*
	Which country has the highest death count?
*/
SELECT location, MAX(CONVERT(int, total_deaths)) highestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highestDeathCount DESC


/*
	Which continent has the highest death count?

	The query below uses CTE to first query the initial result to count total of deaths per country
*/
WITH deathsPerContinent AS
(
SELECT location, continent, MAX(CONVERT(int, total_deaths)) totalDeathsPerCountry
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY continent, totalDeathsPerCountry DESC
)
/*
	Then further sums the total of deaths per country grouped by continent
	Reason: Because of how the dataset is structured being date-based
*/
SELECT continent, SUM(totalDeathsPerCountry) totalDeathsPerCountry
FROM deathsPerContinent
GROUP BY continent
ORDER BY totalDeathsPerCountry DESC


/*
	What is the total cases, deaths, and the percentage of dying globally?
*/
SELECT SUM(new_cases) totalCases
, SUM(CONVERT(int, new_deaths)) totalDeaths
, ((SUM(CONVERT(int, new_deaths)) / SUM(new_cases)) * 100) percentOfDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL


/*
	Provide a breakdown of people getting vaccinated per day by country
*/
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) rollingSumOfVacPerCountry
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location


/*
	What is the percentage of people getting vaccinated per day per country?
		perform further calculations from initial query using Common Table Expressions
*/
WITH percentPeopleVacPerDay AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) rollingSumOfVacPerCountry
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location
)
SELECT *, ((rollingSumOfVacPerCountry / population) * 100)
FROM percentPeopleVacPerDay


/*
	What is the percentage of people getting vaccinated per day per country?
		perform further calculations from initial query using Temp Table
*/
DROP TABLE IF EXISTS #percentPeopleVacPerDay
CREATE TABLE #percentPeopleVacPerDay
(Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population decimal,
New_Vaccinations decimal,
RollingSumOfVacPerCountry decimal)

INSERT INTO #percentPeopleVacPerDay
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) rollingSumOfVacPerCountry
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location

SELECT *, ((RollingSumOfVacPerCountry / Population) * 100) PercentPeopleVacPerDay
FROM #percentPeopleVacPerDay


/*
	Perform visualation at a later stage for the percentage of people getting vaccinated per day per country
*/
CREATE VIEW percentPeopleVacPerDay AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) rollingSumOfVacPerCountry
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location
