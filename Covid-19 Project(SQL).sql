--Questions Answered / Queries Performed:

----Q. What is the percentage of Total Deaths vs Total Cases in each country according to date?
----Q. What the Death Pect. in India?
----Q. What is the Percentage of People got Covid infected with respect to date and location ?
----Q. Which countries has the Highest Infections?
----Q. Which countries has the Highest Infection rates acc. as per its population count?
----Q. Which countries have the highest Mortality rate?
----Q. What Continents having the highest death count?
----Q. Covid Observations on a Global Scale with respect to date.
----Q. What is the Vaccinations percentage according to the Population for each country ?
----Q. Creating our own Total Doses per Day table (ROLLING COUNT).
----Q. Creating a CTE_Table for Additional Calculations in this table.
----Q. Creating a TEMP Table.
----Q. Creating few Important Views(for future Visualisations).
----Q. Creating a Stored Procedure for Getting Stats for specified Country.





--Observing both Tables and its Data.
Select *
From PortfolioProjects.dbo.CovidDeaths
order by 3,4
Select *
From PortfolioProjects..CovidVaccination
order by 3,4;


--Q. What is the percentage of Total Deaths vs Total Cases in each country according to date?
Select Date,Location,total_cases,total_deaths,
total_deaths/total_cases*100 as Death_pect
From PortfolioProjects..CovidDeaths
order by 2,1;


--What the Death Pect. in India?
Select date,Location,total_cases,total_deaths,
total_deaths/total_cases*100 as Death_pect
From PortfolioProjects..CovidDeaths
where location='India'
order by 1,2;
--India has a Max Deathrate of 3.5% , which was recorded in April 2020.
--Current Death Rate(i.e June 2021) in India from Covid is below 1.5%.


--What is the Percentage of People got Covid infected with respect to date and location ?
Select date,Location,total_cases,population,
total_cases/population*100 as Infect_pect
From PortfolioProjects..CovidDeaths
order by 2,1;


--Which countries has the Highest Infections?
Select Location,population,max(total_cases) as Infections, max(total_cases/population)*100 as infect_pect
From PortfolioProjects..CovidDeaths
group by location,population
order by 3 desc;
--as the data is showing continent names in location and their aggregate count as well so we need to eliminate those:
Select Location,population,max(total_cases) as Infections, max(total_cases/population)*100 as infect_pect
From PortfolioProjects..CovidDeaths
where continent is not null
group by location,population
order by 3 desc;
--The most number of infections till date are in United States of America.
--India stands second in list, and Brazil third.

----Which countries has the Highest Infection rates acc. as per its population count?
Select Location,population,max(total_cases) as Infections, max(total_cases/population)*100 as infect_pect
From PortfolioProjects..CovidDeaths
where continent is not null
group by location,population
order by 4 desc;
--Andorra has the highest infection rate as per its population.
--India is way low at 89th rank in this list.


--Which countries have the highest Mortality rate?
Select Location,population,max(cast(total_deaths as int)) as Deaths
From PortfolioProjects..CovidDeaths
where continent is not null
group by location,population
order by 3 desc;
--USA has the most number of total deaths in the world.
--India holds 3rd Position.


--Continents having the highest death count?
Select location,population,max(cast(total_deaths as int)) as Deaths
From PortfolioProjects..CovidDeaths
where continent is null and location<>'World'
group by location,population
order by 3 desc;
--Looks like Europe has the Highest Deaths reported till June 2021.

--GLOBAL NUMBERS:
--Covid Observations on a Global Scale with respect to date:
Select date,sum(new_cases) as NewTotalCases,sum(cast(new_deaths as int)) as Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
group by date
order by 1;

--Total no. of cases till date in the world:
Select sum(new_cases) as NewTotalCases,sum(cast(new_deaths as int)) as Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null
order by 1;


--Joining Covid Deaths and Covid Vaccination tables:
Select *
From PortfolioProjects.dbo.CovidDeaths as CD
join PortfolioProjects..CovidVaccination as CV
on CD.location=CV.location and
CD.date=CV.date


--What is the Vaccinations percentage according to the Population for each country ?
Select CD.Location,population,max(total_vaccinations) as TotalVaccinations ,max(total_vaccinations)/population*100 
From PortfolioProjects.dbo.CovidDeaths as CD
join PortfolioProjects..CovidVaccination as CV
on CD.location=CV.location and
CD.date=CV.date
where CD.continent is not null
group by CD.Location,population
order by 4 desc;
--Since this shows us that the percentage of some countries are going beyond 100%,which means the total vaccinations column is Dose Sensitive.
--i.e it tells us that the no. of doses given in a Country.



--Creating our own Total Doses per Day table (ROLLING COUNT):
Select CD.date,CD.Location,population,(new_vaccinations) as Doses_Given,
sum(cast(new_vaccinations as int)) over (partition by CD.Location order by CD.date) as TotalDoses
From PortfolioProjects.dbo.CovidDeaths as CD
join PortfolioProjects..CovidVaccination as CV
on CD.location=CV.location and
CD.date=CV.date
where CD.continent is not null
order by 2,1;


--Creating a CTE_Table/Temp.Table for Additional Calculations in this table:

--WAY I:-
--Creating CTE:
--Percentage Doses given in each Country as per its Population:
With Doses_table (DATE,LOCATION,POPULATION,DOSES_GIVEN,TOTAL_DOSES)
as
(
Select CD.date,CD.Location,population,(new_vaccinations) as Doses_Given,
sum(cast(new_vaccinations as int)) over (partition by CD.Location order by CD.date) as TotalDoses
From PortfolioProjects.dbo.CovidDeaths as CD
join PortfolioProjects..CovidVaccination as CV
on CD.location=CV.location and
CD.date=CV.date
where CD.continent is not null
)
Select *,(TOTAL_DOSES/POPULATION)*100 as DOSES_vs_POP
from Doses_table

--WAY II:-
--Creating TEMP Table:

Drop Table if Exists #Doses_table

Create Table #Doses_table
(DATE varchar(100),
Location varchar(100),
Population int,
Doses_GIVEN int,
Total_Doses int)
Insert into #Doses_table
Select CD.date,CD.Location,population,(new_vaccinations) as Doses_Given,
sum(cast(new_vaccinations as int)) over (partition by CD.Location order by CD.date) as TotalDoses
From PortfolioProjects.dbo.CovidDeaths as CD
join PortfolioProjects..CovidVaccination as CV
on CD.location=CV.location and
CD.date=CV.date
where CD.continent is not null;
--Adding Percentage Column in our Vaccine Data:
Select *,(TOTAL_DOSES/POPULATION)*100 as pect_doses_given
from #Doses_table


--Creating few Important Views(for future Visualisations):

Create View Continent_deaths as
Select location,population,max(cast(total_deaths as int)) as Deaths
From PortfolioProjects..CovidDeaths
where continent is null and location<>'World'
group by location,population;

Create View Country_infections as
Select Location,population,max(total_cases) as Infections, max(total_cases/population)*100 as infect_pect
From PortfolioProjects..CovidDeaths
where continent is not null
group by location,population;

Create View Country_deaths as
Select Location,population,max(cast(total_deaths as int)) as Deaths
From PortfolioProjects..CovidDeaths
where continent is not null
group by location,population;

-----------------------------------------------------------------------------------------------------
--Creating a Stored Procedure for Getting Stats for specified Country:

Create Procedure Country_Data
@country nvarchar(100)
as
Select CD.date,CD.Location,population,(new_vaccinations) as Doses_Given,
sum(cast(new_vaccinations as int)) over (partition by CD.Location order by CD.date) as TotalDoses,
new_cases,new_deaths,total_deaths
From PortfolioProjects.dbo.CovidDeaths as CD
join PortfolioProjects..CovidVaccination as CV
on CD.location=CV.location and
CD.date=CV.date
where CD.continent is not null
and
CD.location=@country
order by 1;

EXEC Country_Data 'India'
















