select * 
from PortfolioProject..CovidDeaths$;

select * 
from PortfolioProject..CovidVaccinations$;

select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 1,2;

--death percentage
select location,
		date,
		total_cases,
		total_deaths,
		round(100*total_deaths/total_cases,2) as death_percentage
	from PortfolioProject..CovidDeaths$
	Where location like '%India%'
	order by 1,2;

	--total cases vs population
select location,
		date,
		total_cases,
		population,
		round(100*total_cases/population,2) as infected_percentage
	from PortfolioProject..CovidDeaths$
	Where location like '%States%'
	order by 1,2;

	-- Countries with Highest Infection Rate compared to Population
select location,
		population,
		max(total_cases) as total_infected_cases,	
		max(round(100*total_cases/population,2)) as infected_percentage
	from PortfolioProject..CovidDeaths$
	group by location,population
	order by infected_percentage desc;

	-- Countries with Highest Death Count per Population
select location,
	max(cast(total_deaths as int)) as death_count
	from PortfolioProject..CovidDeaths$
	where continent is not null
	group by location
	order by death_count desc;

	-- Showing contintents with the highest death count per population
select continent,
		max(cast(total_deaths as int)) as death_count
		from PortfolioProject..CovidDeaths$
		where continent is not null
		group by continent
		order by death_count desc;

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases,
		sum(cast(new_deaths as int)) as total_deaths,
		100*SUM(cast(new_deaths as int))/SUM(New_Cases) as death_percentage
	from PortfolioProject..CovidDeaths$
	where continent is not null;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select death.continent,
		death.location,
		death.date,
		death.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) 
		OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
		from PortfolioProject..CovidDeaths$ death
		join PortfolioProject..CovidVaccinations$ vac
		On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent,
	death.location,
	death.date, 
	death.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
Join PortfolioProject..CovidVaccinations$ vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as Vaccination_Percentage
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select death.continent,
		death.location, 
		death.date, 
		death.population, 
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
Join PortfolioProject..CovidVaccinations$ vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, 
	death.location, 
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ death
Join PortfolioProject..CovidVaccinations$ vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 

--drop view PercentPopulationVaccinated

select * from PercentPopulationVaccinated;