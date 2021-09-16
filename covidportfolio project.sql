select *
from portfolioproject..coviddeaths
where continent is not null
order by 3,4

--select *
--from portfolioproject..covidvaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population 
from portfolioproject..coviddeaths
where continent is not null
order by 1,2

--totalcases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
order by 1,2

--totalcases vs population(what  pecent of population got covid)

select location,date,total_cases,population,(total_cases/population)*100 as covidpercentage
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
order by 1,2

--countries with highest infection rate compared to population

select location,population,Max(total_cases) as highestinfectioncount,Max(total_cases/population)*100 as highestcovidpercentage
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
group by location,population
order by highestcovidpercentage desc

--countries with highest death rate compared to population

select location,Max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
group by location
order by totaldeathcount desc


--continent wise

--showing continents with highest deathcount

select continent,Max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
group by continent
order by totaldeathcount desc


-- gloabal

select date,sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
group by date
order by 1,2

--total cases and deaths

select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from portfolioproject..coviddeaths
--where location like 'india'
where continent is not null
order by 1,2

--joining two tables

--Looking at total population vs Vaccinations

--cte 
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 as rollingpercent
from PopvsVac

--temp table
-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
