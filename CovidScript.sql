SELECT *
FROM CovidDeaths cd
ORDER by 3,4;

/*SELECT *
FROM CovidVaccinations cv 
ORDER BY 3,4;*/

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths cd 
ORDER BY 1,2;

--Looking at total cases vs. total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,(total_deaths/total_cases)*100 as "Deaths/Cases"
FROM CovidDeaths cd 
WHERE Location like '%states%'
ORDER BY 1,2;

--Looking at the total cases vs. the population
SELECT location,date, total_cases, (total_cases/population)*100 as "Percent of Population Infected"
FROM CovidDeaths cd 
WHERE Location like '%states%'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestCases, MAX((total_cases/population))*100 as "Infection Rate"
FROM CovidDeaths cd 
GROUP BY location, population
ORDER BY "Infection Rate" DESC;


--Looking at countries with highest death count compared to population
SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths cd 
WHERE continent != ''
GROUP BY location
ORDER BY "TotalDeathCount" DESC;


--Breaking down by continent


--Showing the contients with the highest death count per population
SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths cd 
WHERE continent != ''
GROUP BY continent 
ORDER BY "TotalDeathCount" DESC;


--Global Numbers


--Showing death percentage per day by infected people across the world
SELECT location, date, SUM(CAST(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths cd 
--Where location like '%states%'
WHERE  continent != ''
GROUP BY date
ORDER BY 1,2;


--Looking at total population vs vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cv.location Order by cv.location, cv.date) as RollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
and cd.date = cv.date 
WHERE cd.continent != ''
--GROUP BY cd.continent , cd.location , cd.date ,cd.population ,cv.new_vaccinations 
ORDER BY 2,3
;


--Using a CTE 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cv.location Order by cv.location, cv.date) as RollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
and cd.date = cv.date 
WHERE cd.continent != ''
--GROUP BY cd.continent , cd.location , cd.date ,cd.population ,cv.new_vaccinations 
--ORDER BY 2,3
)
Select *, (rollingvaccinations/population)*100
From popvsvac
;




--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cv.location Order by cv.location, cv.date) as RollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
ON cd.location = cv.location 
and cd.date = cv.date 
WHERE cd.continent != ''
--GROUP BY cd.continent , cd.location , cd.date ,cd.population ,cv.new_vaccinations 
--ORDER BY 2,3
;

Select *
FROM PercentPopulationVaccinated;
