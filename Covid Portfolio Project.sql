--       WELCOME TO MY COVID-19 PORTFOLIO PROJECT
--       THIS PROJECT ANALYSES WORLD COVID-19 DATA AND PULLS OUT USEFUL DATA AND CALCULATES USEFUL ADDITIONAL INFORMATION
--       WE ALSO PULL OUT DATA FOR USE IN VISUALIZATIONS IN TABLEAU

-- JUST TAKING A LOOK AT THE DATA BEFORE WE START

SELECT *from [Portfolio covid project].dbo.coviddata
 where continent is not null
order by 3,4

-- LOOKING AT MORE RELEVANT DATA CLOSELY

SELECT location, date,total_cases,total_deaths,population
from [Portfolio covid project].dbo.coviddata
where continent is not null
order by 1,2
 
 -- CALCULATING THE LIKELIHOOD OF DEATH OF COVID PATIENTS IN ZIMBABWE FOR EXAMPLE,

create view DeathLikelihoodZW  as

 SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio covid project].dbo.coviddata
where location like '%zimbabwe%'
and continent is not null
--order by 1,2

-- HOW ABOUT SOUTH AFRICA

create view DeathLikelihoodZA as

 SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio covid project].dbo.coviddata
where location like '%south africa%'
and continent is not null
--order by 1,2


-- A CALCULATION OF THE PERCENTAGE OF CASES TO POPULATION AT ANY GIVEN DATE BY LOCATION

create view CasePercentage as

SELECT location, date,total_cases,population,(total_cases/population)*100 as CasePercentage
from [Portfolio covid project]..coviddata
--where location like '%zimbabwe%'



-- COUNTRIES WITH THE HIGHEST INFECTION RATE

create view InfectionRate as

SELECT location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopInfection
from [Portfolio covid project]..coviddata
group by location,population
--order by PercentPopInfection desc 

-- COUNTRIES WITH HIGHEST DEATH RATES

create view DeathRates as

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((total_deaths/population))*100 as PercentPopDeath
from [Portfolio covid project]..coviddata
group by location
--order by HighestDeathCount desc 

-- BREAKING IT DOWN BY CONTINENT AND/OR REGION

create view DeathRatesRegion as

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((total_deaths/population))*100 as PercentPopDeath
from [Portfolio covid project]..coviddata
where continent is null
group by location

--order by HighestDeathCount desc 


-- GLOBAL NUMBERS

-- WORLD TOTAL CASES by date

create view WorldCasesDeaths as
SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int )) as totalDeaths, SUM(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio covid project].dbo.coviddata
where continent is not null
group by date
--order by 1,2

-- JOINING TWO DATASETS AND CONDUCTING SOME MORE EXPLORATION. THE SECOND DATASET CONTAINS 
-- ALL DATA ON WORLD VACCINATION 

select *
from [Portfolio covid project]..coviddata dea
join [Portfolio covid project]..coviddata1 vac
on dea.location= vac.location
and dea.date = vac.date

-- LET'S CONSIDER TOTAL FULL VACCINATIONS COMPARED TO POPULATION


select dea.continent,dea.location,dea.date,dea.population, vac.people_fully_vaccinated
from [Portfolio covid project]..coviddata dea
join [Portfolio covid project]..coviddata1 vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- HOW ABOUT A COLUMN THAT SHOWS THE TOTAL NUMBER OF PEOPLE FULLY VACCINATED AT ANY GIVEN DATE IN AY GIVEN LOCATION? SIMPLE.

create view TotalFullVaccinations as

select dea.continent,dea.location,dea.date,dea.population, vac.people_fully_vaccinated
,SUM(convert(bigint,vac.people_fully_vaccinated)) over (PARTITION by dea.location order by dea.location,dea.date) as PeopleVacTotal
from [Portfolio covid project]..coviddata dea
join [Portfolio covid project]..coviddata1 vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- NOW AN EXERCISE USING A CTE.

with PopvVac (continent,location,date,population,people_fully_vaccinated,PeopleVacTotal)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.people_fully_vaccinated
,SUM(convert(bigint,vac.people_fully_vaccinated)) over (PARTITION by dea.location order by dea.location,dea.date) as PeopleVacTotal
from [Portfolio covid project]..coviddata dea
join [Portfolio covid project]..coviddata1 vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(PeopleVacTotal/population)*100 as VacPercentage
from PopvVac

-- HOW ABOUT A TEMP TABLE EXERCISE

create table VacPercentageTemp
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVacTotal numeric
)
insert into VacPercentageTemp
select dea.continent,dea.location,dea.date,dea.population, vac.people_fully_vaccinated
,SUM(convert(bigint,vac.people_fully_vaccinated)) over (PARTITION by dea.location order by dea.location,dea.date) as PeopleVacTotal
from [Portfolio covid project]..coviddata dea
join [Portfolio covid project]..coviddata1 vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(PeopleVacTotal/population)*100 as VacPercentage
from VacPercentageTemp


create view VacPercentageTemp1 as

select dea.continent,dea.location,dea.date,dea.population, vac.people_fully_vaccinated
,SUM(convert(bigint,vac.people_fully_vaccinated)) over (PARTITION by dea.location order by dea.location,dea.date) as PeopleVacTotal
from [Portfolio covid project]..coviddata dea
join [Portfolio covid project]..coviddata1 vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null

-- ALL VIEW CREATED WERE FOR USE IN VISUALIZATIONS USING TABLEAU. 

-- THAT'S IT FOR NOW WITH THIS PROJECT. THERE'S MORE TO BE DONE WITH THIS DATA AND THE DATA SOURCE (OWID) IS ALWAYS UPDATING ITS DATABASE.

-- THANK YOU