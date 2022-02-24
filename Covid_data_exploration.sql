/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent <> '' 
order by 1,2


--looking at Total Cases vs Total Deaths
--shows the likelyhood dying if you contract covid in your country

select location,date, total_cases, total_deaths, 
(total_deaths/total_cases) * 100 as DeathPercentage
from coviddeaths
where continent <> '' and location like '%india%'
order by location,date

--looking at Total Cases vs Population
--shows what percentage of Population got covid


select location,date, population, total_cases,
(total_cases/population) * 100 as PercentOfPopulationInfected
from coviddeaths
where continent <> '' 
order by location,date

--looking at countries with highest Infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount
,(max(total_cases)/population) * 100 as PercentOfPopulationInfected
from coviddeaths
where continent <> ''
group by location,population
order by PercentOfPopulationInfected desc

--looking at countries with highest death count per population

select location,  max(total_deaths) as TotalDeathCount
from coviddeaths
where continent <> ''
group by location
order by TotalDeathCount desc


--looking at continents with highest death count per population
--Lets break by Continent
select continent,  max(total_deaths) as TotalDeathCount
from coviddeaths
where continent <> ''
group by continent
order by TotalDeathCount desc


--Global Numbers

select date
	,SUM(new_cases) as total_cases
	,SUM(new_deaths) as total_deaths
	,SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
from coviddeaths
where continent <> ''--location like '%states%'
group by date
order by date


--looking at Total Population vs Vaccinations
--Using CTE

With PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent <> ''
) select * ,case when population = 0 then null else (RollingPeopleVaccinated / population) * 100 end
from PopvsVac
order by 2,3

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date smalldatetime, Population numeric 
	,New_Vaccinations numeric, RollingPeopleVaccinated numeric)
Insert Into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent <> ''

select * ,case when population = 0 then null else (RollingPeopleVaccinated / population) * 100 end as PercentPopulationVaccinated
from #PercentPopulationVaccinated
order by 2,3

--View
CREATE VIEW vPercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(new_vaccinations) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.date = vac.date and dea.location = vac.location
where dea.continent <> ''
--order by 2,3

--selecting records from view
select * ,case when population = 0 then null else (RollingPeopleVaccinated / population) * 100 end as PercentPopulationVaccinated
from vPercentPopulationVaccinated
order by 2,3

