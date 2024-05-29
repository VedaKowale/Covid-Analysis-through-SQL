--SELECT * FROM PortfolioProject..CovidDeaths ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations ORDER BY 3,4

--SELECT Location, date, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS,population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS
--LIKELIHOOD OF DYING IN YOUR COUNTRY
SELECT Location, date, TOTAL_CASES,TOTAL_DEATHS, (total_deaths/total_cases)*100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%STATES%'
ORDER BY 1,2

--TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT Location, date, TOTAL_CASES,population, (total_cases/population)*100 AS CovidPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%STATES%'
AND  continent IS NOT NULL
ORDER BY 1,2

--countries with highest infection rate compared to population
SELECT Location,population,MAX(TOTAL_CASES) AS HighestInfectionCount, MAX((TOTAL_CASES/POPULATION))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population,location
order by PercentagePopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
--CASTED BECAUSE OF DATATYPE
SELECT Location,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNTS
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
order by TOTALDEATHCOUNTS DESC

--WE SEE THAT LOCATIONS HAVE VALUES LIKE WORLD, CONTINENT NAMES ETC
SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SO ABOVE QUERIES WOULD BE MODIFIED TO ADD THE CONTINENT IS NOT NULL

--FILTERING BY CONTINENT
SELECT continent,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNTS
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by TOTALDEATHCOUNTS DESC



--NOrT AMERICA IS NOT INCLUDING NUMBERS FROM CANADA

--Continents with the highest death count oer population
SELECT location,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNTS
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
order by TOTALDEATHCOUNTS DESC

--this above query is giving accurate numbers but ignoring it for now


--GLOBAL NUMBERS
SELECT SUM(NEW_CASES) as total_cases, SUM(cast(NEW_deaths as int)) as total_deaths, SUM(cast(NEW_DEATHS as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%STATES%'
WHERE  continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date

--total population vs vaccination
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations )) OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) as rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
WHERE  death.continent IS NOT NULL
order by 2,3

-- this doesnt allow to run calculations on a newly made column 
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations )) OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) as rollingpeoplevaccinated
,(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
WHERE  death.continent IS NOT NULL
order by 2,3

--hence using CTE
--number of columns in cte and number of column 
--After defining your CTE, you should add a SELECT statement that uses this CTE.
--SO RUN THE SELECT STATEMENT ALONG WITH THE CTE
With PopvsVac (CONTINENT,LOCATION,DATE,POPULATION, new_vaccinations,rollingpeoplevaccinated) 
as
(
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations )) OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
WHERE  death.continent IS NOT NULL
--order by 2,3
)

SELECT * ,(rollingpeoplevaccinated/population)*100
FROM PopvsVac order by 2,3

--TEMP TABLE
--n SQL Server, when you use # before the table name, it creates a local temporary table.
--Temporary tables created with a single # are visible only to the current session.


DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCCINATED
CREATE TABLE #PERCENTPOPULATIONVACCCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATIONS NUMERIC,
ROLLINGPEOPLEVACCINATED NUMERIC,
)


INSERT INTO #PERCENTPOPULATIONVACCCINATED
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations )) OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
--WHERE  death.continent IS NOT NULL
--order by 2,3


SELECT * ,(rollingpeoplevaccinated/population)*100
FROM #PERCENTPOPULATIONVACCCINATED order by 2,3


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PERCENTPOPULATIONVACCINATED as
SELECT death.continent, death.location, death.date, death.population,vac.new_vaccinations
, sum(Convert(int,vac.new_vaccinations )) OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION,DEATH.DATE) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
WHERE  death.continent IS NOT NULL
--order by 2,3