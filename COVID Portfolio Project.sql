--CREATE DATABASE PortfolioProject

--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4

--SELECT location, date, total_cases, total_deaths, ((total_deaths / total_cases) * 100) DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States' AND continent is NOT NULL
--ORDER BY location, date

--SELECT location, date, total_cases, population, ((total_cases / population) * 100) CasePercentage
--FROM PortfolioProject..CovidDeaths
--WHERE location = 'Philippines' AND continent is NOT NULL
--ORDER BY location, date

--SELECT location, population, MAX(total_cases) HighestInfetionRate, MAX((total_cases / population) * 100) HighestInfectionRate
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY location, population
--ORDER BY HighestInfectionRate DESC

--SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY HighestDeathCount DESC

--SELECT date, SUM(new_cases) TotalCases, SUM(CAST(new_deaths AS int)) TotalDeaths, ((SUM(CAST(new_deaths AS int))) / SUM(new_cases) * 100) PercentageDeath
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1

--SELECT SUM(new_cases) TotalCases, SUM(CAST(new_deaths AS int)) TotalDeaths, ((SUM(CAST(new_deaths AS int))) / SUM(new_cases) * 100) PercentageDeath
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL

--SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations
--FROM PortfolioProject..CovidDeaths deaths
--INNER JOIN PortfolioProject..CovidVaccinations vaccs
--	ON deaths.location = vaccs.location
--	AND deaths.date = vaccs.date
--WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3

--SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
--SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingSumOfPeopleVaccinated
--FROM PortfolioProject..CovidDeaths deaths
--INNER JOIN PortfolioProject..CovidVaccinations vaccs
--	ON deaths.location = vaccs.location
--	AND deaths.date = vaccs.date
--WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3

--WITH PopOverVaccs (continent, location, date, population, new_vaccinations, RollingSumOfPeopleVaccinated) AS
--(
--SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
--SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingSumOfPeopleVaccinated
--FROM PortfolioProject..CovidDeaths deaths
--INNER JOIN PortfolioProject..CovidVaccinations vaccs
--    ON deaths.location = vaccs.location
--    AND deaths.date = vaccs.date
--WHERE deaths.continent IS NOT NULL
--)
--SELECT *, (RollingSumOfPeopleVaccinated / population) * 100 AS RollingPercentageOfPeopleVaccinated
--FROM PopOverVaccs
--ORDER BY location
--WITH PopOverVaccs (continent, location, date, population, new_vaccinations, RollingSumOfPeopleVaccinated) AS
--(
--SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
--SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingSumOfPeopleVaccinated
--FROM PortfolioProject..CovidDeaths deaths
--INNER JOIN PortfolioProject..CovidVaccinations vaccs
--    ON deaths.location = vaccs.location
--    AND deaths.date = vaccs.date
--WHERE deaths.continent IS NOT NULL
--)
--SELECT location, population, SUM(CONVERT(int, new_vaccinations)) AS SumOfPeopleVaccinated,
--(MAX(RollingSumOfPeopleVaccinated / population)) * 100 AS PercentageOfPeopleVaccinated
--FROM PopOverVaccs
--GROUP BY location, population
--ORDER BY location

--DROP TABLE IF EXISTS #PopVsVac
--CREATE TABLE #PopVsVac
--(continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccination numeric,
--rollingSumOfPeopleVaccinated numeric)
--INSERT INTO #PopVsVac
--SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
--SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingSumOfPeopleVaccinated
--FROM PortfolioProject..CovidDeaths deaths
--INNER JOIN PortfolioProject..CovidVaccinations vaccs
--    ON deaths.location = vaccs.location
--    AND deaths.date = vaccs.date
--WHERE deaths.continent IS NOT NULL
--SELECT *, (RollingSumOfPeopleVaccinated / population) * 100 AS RollingPercentageOfPeopleVaccinated
--FROM #PopVsVac

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
SUM(CONVERT(int, vaccs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.date) AS RollingSumOfPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
INNER JOIN PortfolioProject..CovidVaccinations vaccs
    ON deaths.location = vaccs.location
    AND deaths.date = vaccs.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated