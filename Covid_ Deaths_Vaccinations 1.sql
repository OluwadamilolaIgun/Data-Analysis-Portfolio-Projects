Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 3,4



--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--Order by 3,4

----- Select Data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2

--- Total cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%nigeria%'
Where continent is not null
order by 1,2

 
 --- Total cases vs Population
 ----- Perentage of popuation that got Covid

Select Location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%nigeria%'
Where continent is not null
order by 1,2


------ Highest infection rate per Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
---Where location like '%nigeria%'
Group by location, population
order by PercentPopulationInfected desc

------ Countries with Highest Covid Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
---Where location like '%nigeria%'
Where continent is not null
Group by location
order by TotalDeathCount desc

------ Continent with Highest Covid Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
---Where location like '%nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



---- Global Stats
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
---Where location like '%nigeria%'
Where continent is not null
Group by date
order by 1,2


----Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
---, (RollingVaccinations/Population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
---Order by 2,3
)

Select *, (RollingVaccinations/Population)*100
From PopvsVac

---Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
---, (RollingVaccinations/Population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
---Order by 2,3


Select *, (RollingVaccinations/Population)*100
From #PercentPopulationVaccinated


----For Later Visualisations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
---, (RollingVaccinations/Population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select*
From PercentPopulationVaccinated