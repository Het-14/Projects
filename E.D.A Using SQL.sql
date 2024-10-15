select location, date, total_cases, new_cases ,total_deaths, population
from CovidDeaths$ 
order by 1,2;

-- Looking at Total Cases vs Total Death 
-- Represents Likelihood of dying if you had covid in India
select location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100, 2) as DeathPercentage
from CovidDeaths$
where location like 'india'
order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of Population got covid
select location, date, total_cases, population, Round((total_cases/population)*100, 4) as InfectedPercentage
from CovidDeaths$
where location like 'india'
order by 1,2;

-- Countries with Highest Infection Rate to population
select location, MAX(total_cases) as HighestInfectionCount, population, Round((MAX(total_cases)/population)*100, 4) as PercentagePopulationInfected
from CovidDeaths$
where continent is not null
Group by location, population
order by PercentagePopulationInfected desc;

-- Showing countries with highest DeathCount
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
Group by location, population
order by TotalDeathCount desc;

-- Showing Continents with Highest DeathCount
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
select Date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, (SUM(new_cases)/SUM(cast(new_deaths as int)))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
Group by date
order by date;


-- Exploring Data Along another table i.e, Covid Vaccinations
select *
from CovidVaccinations$;

-- Joining Both Tables
select *
from CovidDeaths$
join CovidVaccinations$ on CovidDeaths$.location = CovidVaccinations$.location 
	and CovidDeaths$.date = CovidVaccinations$.date;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from CovidDeaths$ as dea
join CovidVaccinations$ as vac on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3;

-- Using CTE 
-- TotalVaccinations VS Population
with PopvsVac (Continent, Location, Date, Population, NewVaccination, TotalVaccinations)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinations
from CovidDeaths$ as dea
join CovidVaccinations$ as vac on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
)
select *, Round((TotalVaccinations/Population)*100, 2) as PercentagePopulationVaccinated
from PopvsVac;

