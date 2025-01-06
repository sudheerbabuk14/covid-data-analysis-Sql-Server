use project2

--select data that we are going to be using
 
 select 
 location,date,total_cases,new_cases,total_deaths,population
 from coviddeaths
 order by 1,2;

-- looking at total cases vs total deaths
--show likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as deathpercentage 
from coviddeaths
order by 1,2 desc;


select location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as deathpercentage 
from coviddeaths
where location like '%india%'
order by 1,2 desc;

--looking total cases vs population
--shows what percentage of population got covid in india

select location,date,total_cases,population,
(total_cases/population)*100 as total_cases_percentage
from coviddeaths
where location like '%india%'
order by 1,2;

--loking at countries with highest infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount,
max(total_cases/population)*100 as percentpopulationinfected 
from coviddeaths
--where location like '%india%'
group by location,population
order by location,population desc; 

--showing countries with highest death count per population

select location, max(total_deaths) as maxdeaths
from coviddeaths 
group by location
order by maxdeaths desc ;

--lets break things down by continent

select continent,max(cast(total_deaths as int)) as totaldeathcount
from coviddeaths
where continent is not null
group by
continent
order by totaldeathcount desc;

select continent ,max(cast(total_deaths as int)) as maxdeathcount 
from coviddeaths
where continent is not null
group by continent
order by maxdeathcount desc;

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from coviddeaths dea
join
covidvaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3;


--using cte to perform calculation on partition by in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--using temp table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

