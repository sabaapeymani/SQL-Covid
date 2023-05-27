SELECT * FROM [Covid-19].CovidDeaths
where continent is not NULL
ORDER BY 3,4
; 

 
 
 -- Added
 
 Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM [Covid-19].CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location





SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX(CAST(total_cases AS float)/Population)*100 AS PercentPopulationInfected
FROM [Covid-19].CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC




SELECT location, 
       population, 
			 [date],
       MAX(CAST(total_cases AS FLOAT)) AS HighestInfection, 
       MAX(CAST(total_cases AS FLOAT)/population) * 100 AS PercentPopulationInfected
FROM [Covid-19].CovidDeaths
GROUP BY location, population, [date]
ORDER BY PercentPopulationInfected DESC

--- End of Add
 
 
 
 
SELECT * FROM [Covid-19].CovidVaccinations
ORDER BY 3,4
; 


SELECT location,date, total_cases, new_cases, total_deaths, population
FROM [Covid-19].CovidDeaths
ORDER BY 1,2

-- Looking at total cases versus total CovidDeaths
-- shows likelihood of dying if you contracting covid in your country


SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float) / CAST(total_cases AS float)*100 as DeathPercentage
FROM [Covid-19].CovidDeaths
where location like '%states%'
ORDER BY location, date
;


-- looking total cases vs population
-- shows what percentage got covid


SELECT location, date, population, total_cases, CAST(total_cases AS float) / CAST(population AS float)*100 as DeathPercentage
FROM [Covid-19].CovidDeaths
--where location like '%Iran%'
ORDER BY location, date
;


-- what countries have most infection rate compared to population

SELECT location, 
       population, 
       MAX(CAST(total_cases AS FLOAT)) AS HighestInfection, 
       MAX(CAST(total_cases AS FLOAT)/population) * 100 AS PercentPopulationInfected
FROM [Covid-19].CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--showing countries with highest deth count per population
--Lets Breaking down by continent
--Showing continent with highest death per population



SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Covid-19].CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
-- -- 
-- 
-- Global NUMBERS

SELECT SUM(CAST(new_cases as float)) as total_cases, 
       SUM(CAST(new_deaths as INT)) as total_deaths, 
       SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float)) * 100 as DeathPercentage
FROM [Covid-19].CovidDeaths
WHERE continent is not NULL
GROUP BY [date]
ORDER BY 1, 2




-- Lokking at Total population vs vaccination


select * 
FROM [Covid-19].CovidDeaths dea
JOIN [Covid-19].CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.[date];

;



-- USE CTE

with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, VaccinationPercentage)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated,
       CAST((SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)/CAST(dea.population AS float))*100 AS decimal(10,2)) as VaccinationPercentage
FROM [Covid-19].CovidDeaths dea
JOIN [Covid-19].CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.[date]
WHERE dea.continent is not NULL
)

SELECT *
FROM PopvsVac;




-- TEMP TABLE




DROP TABLE if EXISTS #PercentagePopulationVaccinated;

CREATE TABLE #PercentagePopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric,
    VaccinationPercentage decimal(10,2)
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated,
       CAST((SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)/CAST(dea.population AS float))*100 AS decimal(10,2)) as VaccinationPercentage
FROM [Covid-19].CovidDeaths dea
JOIN [Covid-19].CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.[date]
--WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated



--CREATING VIEW TO STORE DATA LATER FOR VISUALIZATION
DROP VIEW IF EXISTS PercentagePopulationVaccinated;
GO

CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated,
       CAST((SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING)/CAST(dea.population AS float))*100 AS decimal(10,2)) AS VaccinationPercentage
FROM [Covid-19].CovidDeaths dea
JOIN [Covid-19].CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.[date]
WHERE dea.continent IS NOT NULL;
GO


