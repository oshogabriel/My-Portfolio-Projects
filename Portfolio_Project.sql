--SELECT *
--FROM Potfolio_Project.dbo.['Covid Vaccination$']
--ORDER BY 3,4


--SELECT *
--FROM Potfolio_Project.dbo.['Covid Death$']
--ORDER BY 3,4

--selecting the required data for this project

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM Potfolio_Project.dbo.['Covid Death$']
ORDER BY 1,2


-- Comparing total cases to total death
-- The probability of death from contracting covid_19 in Nigeria

SELECT Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 as Death_Percentage
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE Location like 'Nigeria'
ORDER BY 1,2


--Comparing total cases to population
-- Explains the probability of contracting Covid_19 in Nigeria

SELECT Location, Date, Population, Total_cases, (Total_cases/Population)*100 as Infection_Percentage_Rate
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE Location like 'Nigeria'
ORDER BY 1,2

--Country with highest infection rate, death rate, percentage of infected and percentage of death

SELECT Location,Population, MAX(Total_cases) as Highest_Infected_Count, MAX(Total_Deaths) as Highest_Death_Count, MAX((Total_cases/Population))*100 as Infected_Population_Percent, MAX((Total_deaths/Population))*100 as Death_Population_Percent
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE continent is NOT Null
GROUP BY Location, Population
ORDER BY Infected_Population_Percent desc


--Highest death count per country and population

SELECT Location,MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE continent is NOT Null
GROUP BY Location
ORDER BY Total_Death_Count desc

--
SELECT Location,MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE continent is Null
GROUP BY Location
ORDER BY Total_Death_Count desc

--

SELECT continent,MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE continent is NOT Null
GROUP BY continent
ORDER BY Total_Death_Count desc


--Global numbers

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_deaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
--- Total_deaths, (Total_deaths/Total_cases)*100 as Death_Percentage
FROM Potfolio_Project.dbo.['Covid Death$']
WHERE continent is NOT Null
--GROUP BY date
ORDER BY 1,2 

--
SELECT *
FROM Potfolio_Project.dbo.['Covid Vaccination$']
ORDER BY 1,2

-- Total Population Vs Vaccinations 
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT Dea.continent, Dea.Location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(int, Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.Location, 
		Dea.date) as RollingPeopleVaccinated
FROM Potfolio_Project.dbo.['Covid Death$'] Dea
join Potfolio_Project.dbo.['Covid Vaccination$'] Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent is not null
ORDER BY 2, 3

--

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT Dea.continent, Dea.Location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(int, Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.Location, 
		Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Potfolio_Project.dbo.['Covid Death$'] Dea
join Potfolio_Project.dbo.['Covid Vaccination$'] Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
WHERE Dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Vaccinated_People_Percent
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
SELECT Dea.continent, Dea.Location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(int, Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.Location, 
		Dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Potfolio_Project.dbo.['Covid Death$'] Dea
join Potfolio_Project.dbo.['Covid Vaccination$'] Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT Dea.continent, Dea.Location, Dea.date, Dea.population, Vac.new_vaccinations, 
		SUM(CONVERT(int, Vac.new_vaccinations)) OVER(PARTITION BY Dea.location ORDER BY Dea.Location, 
		Dea.date) as RollingPeopleVaccinated
FROM Potfolio_Project.dbo.['Covid Death$'] Dea
join Potfolio_Project.dbo.['Covid Vaccination$'] Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated