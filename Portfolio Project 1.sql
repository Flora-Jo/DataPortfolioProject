

--Select *
--From PortfolioProject.  .CovidDeaths
--Where continent is NOT NULL 
--Order By 3,4

--Select *
--From PortfolioProject.  .CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.  .CovidDeaths
Where continent is NOT NULL 
Order By 1,2

----Looking at Total Cases Vs Total Deaths
----Shows the Likelihood of dying if you contact Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As 'DeathPercentage'
From PortfolioProject.  .CovidDeaths
Where Location = '%Kenya%'
Order By 1,2


----Looking at the Total Cases Vs Population
----Shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 As 'InfectionRate'
From PortfolioProject.  .CovidDeaths
Where Location = 'Kenya'
Order By 1,2


----Looking at Countries with Highest Infection Rate Compared with Population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 As 'PercentPopulationInfected'
From PortfolioProject.  .CovidDeaths
Where continent is NOT NULL 
Group By Location, Population
Order By PercentPopulationInfected Desc


----Showing Countries with Highest Death Count Per Population
Select Location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 As 'PopulationDeathRate'
From PortfolioProject.  .CovidDeaths
Where continent is NOT NULL 
Group By Location, Population
Order By TotalDeathCount Desc

----Breaking Death Count Down by Continent
Select Location, population, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 As 'PopulationDeathRate'
From PortfolioProject.  .CovidDeaths
Where continent is NULL 
Group By Location, Population
Order By TotalDeathCount Desc  -------CORRECT QUERY

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.  .CovidDeaths
Where continent is not NULL 
Group By continent
Order By TotalDeathCount Desc



----GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As 'DeathPercentage'
From PortfolioProject.  .CovidDeaths
Where Continent is not Null
--Group By date
Order By 1,2

----Looking at Total Population vs Vaccinations

Select Death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations,
From PortfolioProject.  .CovidDeaths as Death
Join PortfolioProject.  .CovidVaccinations as Vacc
  On Death.location = Vacc.location
  and death.date = vacc.date
Where Death.continent is not null
Order by 1,2,3

Select Death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations,
Sum(Convert(int, vacc.new_vaccinations)) Over (Partition By Death.Location Order By Death.Location, Death.Date) as RollingNumVaccinations
From PortfolioProject.  .CovidDeaths as Death
Join PortfolioProject.  .CovidVaccinations as Vacc
  On Death.location = Vacc.location
  and death.date = vacc.date
Where Death.continent is not null
Order by 2,3

----Use CTE

With PopvsVacc (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations,
Sum(Convert(int, vacc.new_vaccinations)) Over (Partition By Death.Location Order By Death.Location, Death.Date) as RollingNumVaccinations
From PortfolioProject.  .CovidDeaths as Death
Join PortfolioProject.  .CovidVaccinations as Vacc
  On Death.location = Vacc.location
  and death.date = vacc.date
Where Death.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
From PopvsVacc


----Temp Table

Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
Select Death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations,
Sum(Convert(int, vacc.new_vaccinations)) Over (Partition By Death.Location Order By Death.Location, Death.Date) as RollingNumVaccinations
From PortfolioProject.  .CovidDeaths as Death
Join PortfolioProject.  .CovidVaccinations as Vacc
  On Death.location = Vacc.location
  and death.date = vacc.date
Where Death.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
From #PercentPopulationVaccinated


----Creating View To Store Data for Visualizations

Create View PercentPopulationVaccinated as
Select Death.continent, Death.location, Death.date, Death.population, vacc.new_vaccinations,
Sum(Convert(int, vacc.new_vaccinations)) Over (Partition By Death.Location Order By Death.Location, Death.Date) as RollingNumVaccinations
From PortfolioProject.  .CovidDeaths as Death
Join PortfolioProject.  .CovidVaccinations as Vacc
  On Death.location = Vacc.location
  and death.date = vacc.date
Where Death.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated