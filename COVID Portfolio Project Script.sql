select *
From PortfolioProject..['Covid Deaths$']
where continent is not null
order by 3,4

--select *
From PortfolioProject..['Covid Vaccination$']
order by 3,4

--Select Data that we are using in this project

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
shows the likelyhood of dying should you contact covid in united kingdom
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
where location like '%Kingdom%'
order by 1,2


--looking at Total Cases vs Population
--shows what percentage of population got covid

Select location, date, total_cases, total_deaths, (total_cases/population)*100 as Percentage_Population_infected
From PortfolioProject..['Covid Deaths$']
where location like '%Kingdom%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compare to population

	Select location, population, MAX(total_cases) as highestInfectionCount, MAX(total_cases/population)*100 as Percentage_Population_infected
	From PortfolioProject..['Covid Deaths$']
	--where location like '%Kingdom%'
	Group by location, population
	order by Percentage_Population_infected desc


	--LETS BREAK THINGS DOWN BY CONTINENT

	--showing continents with highest death count

	Select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
	From PortfolioProject..['Covid Deaths$']
	--where location like '%Kingdom%'
	where continent is not null
	Group by continent
	order by TotaldeathCount desc

	--GLOBAL NUMBER 
SELECT 
    SUM(new_cases) as total_cases, 
    SUM(cast(new_deaths as int)) as total_deaths, 
    SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM 
    PortfolioProject..['Covid Deaths$']
WHERE 
    continent IS NOT NULL
--GROUP BY 
--    date
ORDER BY 
    1,2


--Looking at Total Population Vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$']  dea
join PortfolioProject..['Covid Vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$']  dea
join PortfolioProject..['Covid Vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVac
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$']  dea
join PortfolioProject..['Covid Vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to Store data for later Visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['Covid Deaths$']  dea
join PortfolioProject..['Covid Vaccination$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated


