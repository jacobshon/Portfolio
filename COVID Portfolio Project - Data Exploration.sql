SELECT *
From covid_deaths
WHERE continent is not null
order by 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
order by 1,2;

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
FROM covid_deaths
WHERE location = 'United States'
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date,population, total_cases, (total_cases/population) *100 as PercentPopulationInfected
FROM covid_deaths
WHERE location = 'United States'
order by 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
FROM covid_deaths
--WHERE location = 'United States'
Group by Location, Population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count Per Population
SELECT LOCATION, MAX(cast(Total_deaths as int)) as TotaDeathCount
FROM covid_deaths
WHERE continent is not null
Group by Location
order by TotaDeathCount desc;

--Showing Continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as TotaDeathCount
FROM covid_deaths
WHERE continent is not null
Group by continent
order by TotaDeathCount desc;

--Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM covid_deaths
where continent is not null
order by 1,2;

--Looking. at Total Population vs Vaccinations

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac;

--TEMP Table
Drop table if exists PercentPopulationVaccinated;
Create Temporary Table PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated;

--Creating View to store data for later visualizations
Create VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select *
FROM PercentPopulationvaccinated;