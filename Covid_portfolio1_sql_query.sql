SELECT *
fROM PortfolioProject.dbo.CovidDeaths
WHere continent is not null
order by 3,4

SELECT *
fROM PortfolioProject.dbo.CovidVaccinations
WHere continent is not null
order by 3,4

--Select the data to be used--

SELECT location,continent,date,total_cases,new_cases, total_deaths,population
fROM PortfolioProject.dbo.CovidDeaths
WHere continent is not null
order by 1,2

--total cases vs total deaths--

SELECT location,continent,date,total_cases, total_deaths , (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
and location like '%India%'
order by 1,2

--total cases vs population--

SELECT location,continent,date,population,total_cases, (CAST(total_cases AS float) / CAST(population AS float))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--where location like '%India%'
order by 1,2


--Countries with highest infection rate vs populatio--

SELECT continent,population,Max(total_cases) as HighestInfectionCount, MAX((CAST(total_cases AS float) / CAST(population AS float)))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%India%'
WHERE continent is not null
group by continent,population
order by PercentPopulationInfected DESC

--COUNTRIES WITH MAXIMUM DEATH COUNT PER POPULATION--

SELECT continent,population , MAX(CAST(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHere continent is not null
GROUP BY continent,population
ORDER BY TotalDeathCount DESC;

--By continent--
--continents with highest death counts--

SELECT location , MAX(CAST(total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHere continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Global Numbers --

SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CASE 
            WHEN new_cases = 0 THEN 0
            ELSE CAST(new_deaths AS int)
        END) * 100.0 / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM 
    PortfolioProject.dbo.CovidDeaths 
WHERE 
    continent IS NOT NULL
   
GROUP BY 
    date 
ORDER BY 
    date, total_cases;

	-------------------------------------------------------------------------------------------------------------------------------------


-----------total population vs new population-------

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		Sum (cast(vac.new_vaccinations as int)) over( partition by dea.location  order by dea.location ,dea.date) as RollingPeopleVaccinationed
FROM PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

With PopVsVac (Continent, location, date , population, new_vaccinations ,RollingPeopleVaccinationed)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		Sum (cast(vac.new_vaccinations as int)) over( partition by dea.location  order by dea.location ,dea.date) as RollingPeopleVaccinationed
FROM PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select* , (RollingPeopleVaccinationed / population)*100
From PopVsVac


--Temp Table--

DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations  numeric,
RollingPeopleVaccinationed numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		Sum (cast(vac.new_vaccinations as int)) over( partition by dea.location  order by dea.location ,dea.date) as RollingPeopleVaccinationed
FROM PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select* , (RollingPeopleVaccinationed / population)*100 PercentPopulationVaccinated
From #PercentPopulationVaccinated

---CReating Views--

Create View PercentPopulationVaccinatedd as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		Sum (cast(vac.new_vaccinations as int)) over( partition by dea.location  order by dea.location ,dea.date) as RollingPeopleVaccinationed
FROM PortfolioProject.dbo.CovidDeaths dea
join  PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
From PercentPopulationVaccinatedd