select * from Portfolio_Proyect.dbo.DeathCovid

--select * from Portfolio_Proyect.dbo.CovidVaccinations 
--order by 5


-- Seleccionamos lso datos que vamos a usar


select location, date, total_cases, new_cases, total_deaths, population 
from Portfolio_Proyect.dbo.DeathCovid order by 1,2 



-- Vamos a ver el Total de casos vs el Total de Muerte
--Porcentaje de personas que murieron que se les diagnostico 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage 
from Portfolio_Proyect.dbo.DeathCovid
order by 1,2


-- Probabilidad de morir si contraes covid en tu pais

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage 
from Portfolio_Proyect.dbo.DeathCovid
where location like '%argentina%'
order by 1,2




-- Comparacion de total de casos contra poblacion
-- Porcentaje de la poblacion que contrajo covid en Argentina

select location,date,population, total_cases,round((total_cases/population)*100,4) as CovidPercentage 
from Portfolio_Proyect.dbo.DeathCovid
where location like '%argentina%'
Order By 1,2




-- Paises con mayor tasa de infeccion en comparacion con la poblacion

select location,population,MAX(total_cases) as Mayor_Infec, (MAX(total_cases/population))*100 as CovidPercentage  
from Portfolio_Proyect.dbo.DeathCovid
group by location,population
order by CovidPercentage desc



-- Paises con mayor tasa de muertes por poblacion

select location,MAX(total_deaths) as TotalDeaths
from Portfolio_Proyect.dbo.DeathCovid
where continent is not null
group by location
order by TotalDeaths desc 





-- Continentes con mayor tasa de muertes por poblacion

select location,MAX(total_deaths) as TotalDeaths
from Portfolio_Proyect.dbo.DeathCovid
where continent is null and location not like '%income%'
group by location
order by TotalDeaths desc




-- Estadisticas globales

select  SUM(new_cases) as new_cases,SUM(new_deaths) as new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as percentage
from Portfolio_Proyect.dbo.DeathCovid 
where continent is not null
HAVING SUM(new_cases) != 0
order by 1,2






-- Poblacion Total vs Vacunas totales

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY CONVERT(DATE, dea.date)) AS RollingPeopleVaccinated
FROM Portfolio_Proyect.dbo.DeathCovid dea
JOIN Portfolio_Proyect.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;




-- Uso de CTE : característica de SQL que permite definir una consulta nombrada y utilizarla como una tabla temporal 
-- dentro de una consulta principal




WITH PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY CONVERT(DATE, dea.date)) AS RollingPeopleVaccinated
    FROM Portfolio_Proyect.dbo.DeathCovid dea
    JOIN Portfolio_Proyect.dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as percentage
FROM PopvsVac
ORDER BY 2,3;




-- Tabla temporal

DROP Table if exists #PercentPopulationVac
CREATE TABLE #PercentPopulationVac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY CONVERT(DATE, dea.date)) AS RollingPeopleVaccinated
    FROM Portfolio_Proyect.dbo.DeathCovid dea
    JOIN Portfolio_Proyect.dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL




SELECT *, (RollingPeopleVaccinated/Population)*100 as percentage
FROM #PercentPopulationVac
ORDER BY 2,3;









-- Creaciones de VIEWS para almacenar datos para visualizaciones posteriores

create View  PercentPopulationVac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY CONVERT(DATE, dea.date)) AS RollingPeopleVaccinated
    FROM Portfolio_Proyect.dbo.DeathCovid dea
    JOIN Portfolio_Proyect.dbo.CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL



Select * from PercentPopulationVac


