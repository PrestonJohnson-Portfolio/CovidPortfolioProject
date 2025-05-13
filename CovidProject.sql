--Preston Johnson
--Covid Cases Project


select * 
from PortfolioProject..CovidDeaths$	--view covid deaths table, order by column 3 and 4
where continent is not null
order by 3,4

-- get data were going to be using 
select location, date, total_cases, new_cases, total_deaths, population		
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--total cases vs total deaths, will show how likely you are to die if infected
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--total cases vs population, will show percentage of population that got covid
select location, date, total_cases,population, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths$
order by 1,2

--countries whith the highest infection rate by population
select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CasePercentage
from PortfolioProject..CovidDeaths$
group by population, location
order by CasePercentage desc


--countries with the highest death count by population
select location, max(cast(total_deaths as int)) as TotalDeathCount  --total deaths column is an nvarchar and was producing false results, converted to int to fix
from PortfolioProject..CovidDeaths$									
where continent is not null					    --want location information that has a continent value also, 
group by  location						    -- is not null gets rid of rows with continent names that are listed as location 
order by TotalDeathCount desc

--continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount   --same nvarchar issue, cast as int
from PortfolioProject..CovidDeaths$		
where continent is not null
group by continent
order by TotalDeathCount desc


--global counts
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage  
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- total population vs vaccinations, partion by allows for keeping a running count while still having other columns
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	--cte, used cte so RollingPeopleVaccinations can be divided by population, used cte instead of making a temporary table
with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinations)
	as
	(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
select *, ((RollingPeopleVaccinations/Population)*100) as PercentOfPopulation
from PopVsVac

--view for later data storage
create view PopVsVac as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

select * 
from PopVsVac

