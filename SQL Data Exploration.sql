select *
from [Portfolio Project]..CovidDeaths
where continent is not null 
order by 3,4

--select *
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

--Select the data that we are going to using

select location,date, total_cases, new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths 
-- Shows liklihood of dying if you contract covid in your country
select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at Total Cases Vs Population
-- shows what percentage of population got Covid
select location,date, total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%Syria%'
order by 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%Syria%'
Group by location, population 
order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%Syria%'
where continent is not null 
Group by  location
order by TotalDeathCount desc

-- LET's Break Things Down By Continent
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%Syria%'
where continent is not null 
Group by  continent
order by TotalDeathCount desc


-- Showing Contintents with the highest Death Count per Population 
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%Syria%'
where continent is not null 
Group by  continent
order by TotalDeathCount desc



-- Global Numbers

select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingpeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated