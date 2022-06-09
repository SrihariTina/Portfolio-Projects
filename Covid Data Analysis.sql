--select * 
--from ..CovidDeaths$
--where continent is not null
--order by 3,4

--select * 
--from ..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
order by 1,2

-- looking at total deaths vs total cases
-- shows the likelihood of death if you contract covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths$ where location ='India'
order by 1,2

-- looking at total cases vs population

select location, date, total_cases, population, (total_deaths/population)*100 as Percentage_of_covidcases
from [Portfolio Project]..CovidDeaths$ where location ='India'
order by 1,2

-- looking at countries with the highest infection compared to population

select location, max(total_cases) as highest_infection_count, population, max(total_cases/population)*100 as PercentageOfPopulationInfected
from [Portfolio Project]..CovidDeaths$ 
--where location ='India'
group by location,population
order by PercentageOfPopulationInfected desc

-- show countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths$ 
--where location ='India'
where continent is not null
group by location
order by totaldeathcount desc

--show countries with highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths$ 
--where location ='India'
where continent is not null
group by continent
order by totaldeathcount desc

--proper one is below

select location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths$ 
--where location ='India'
where continent is null
group by location
order by totaldeathcount desc

--Global Numbers

select date, sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$ 
--where location ='India'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_Cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$ 
--where location ='India'
where continent is not null
--group by date
order by 1,2

-- looking at the population vs total vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinatedPopulation
from [Portfolio Project].[dbo].[CovidDeaths$] dea
join [Portfolio Project].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE ( common table expression )

with PopVsVac (continent, location, date, Population , new_vaccinations, RollingPeopleVaccinated )
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated --,RollingPeopleVaccinated/population)*100
from [Portfolio Project].[dbo].[CovidDeaths$] dea
join [Portfolio Project].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 from PopVsVac

-- Using Temp table

Drop table if exists #PopvsVac
Create table #PopvsVac (
Continent varchar(255),
Location varchar(255),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated int)

Insert into #PopvsVac 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Portfolio Project].[dbo].[CovidDeaths$] dea
join [Portfolio Project].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 from #PopvsVac


--- creating view for later visualizations

Create View xyz as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Portfolio Project].[dbo].[CovidDeaths$] dea
join [Portfolio Project].[dbo].[CovidVaccinations$] vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3