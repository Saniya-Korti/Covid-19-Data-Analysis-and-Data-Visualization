SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Selecting the data which we're going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at total_cases VS total_deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,(total_cases/total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%ndia'
ORDER BY 1,2

--Looking at total_cases VS population
--Shows what percentage of population got covid

SELECT location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%ndia%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectiousRate, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ndia%'
GROUP BY location,Population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ndia%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCounts desc

--Breaking it by continents

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ndia%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCounts desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--WHERE location like '%ndia%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCounts desc

--Showing the continent with the highest death count per population


--Global numbers

SELECT date,SUM(New_cases) as total_cases,SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(New_cases) as total_cases,SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Using Join

SELECT * 
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacci 
ON Death.location = Vacci.location and
 Death.date = Vacci.date

 --Looking at total population VS Vaccinations

SELECT Death.continent, Death.location, Death.date, Death.population, Vacci.New_Vaccinations
 , SUM(CONVERT(int, Vacci.New_Vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location,Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacci 
ON Death.location = Vacci.location and
 Death.date = Vacci.date
 WHERE Death.continent is not null
 ORDER BY 2,3

 --Use CTE

WITH Popvsvac (continent, Location,date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vacci.New_Vaccinations
 , SUM(CONVERT(int, Vacci.New_Vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location,Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacci 
ON Death.location = Vacci.location and
 Death.date = Vacci.date
 WHERE Death.continent is not null
 --ORDER BY 2,3
 )
 SELECT *,(RollingPeopleVaccinated/Population) * 100
 FROM Popvsvac 

 --Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Death.continent, Death.location, Death.date, Death.population, Vacci.New_Vaccinations
 , SUM(CONVERT(int, Vacci.New_Vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location,Death.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacci 
ON Death.location = Vacci.location and
 Death.date = Vacci.date
WHERE Death.continent is not null
--ORDER BY 2,3
SELECT *,(RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated


--Creating View to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vacci.New_Vaccinations
 , SUM(CONVERT(int, Vacci.New_Vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location,Death.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death
JOIN PortfolioProject..CovidVaccinations Vacci 
ON Death.location = Vacci.location and
 Death.date = Vacci.date
WHERE Death.continent is not null
--ORDER BY 2,3

--opening View

SELECT * FROM PercentPopulationVaccinated

--Tableau Visualization

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
