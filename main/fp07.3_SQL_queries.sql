-- DROP VIEW IF EXISTS view_total_establishments_by_region_with_size_order;
CREATE VIEW view_total_establishments_by_region_with_size_order AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(e.total_establishment) DESC) AS order_number,        
    ge.region_name,         
    SUM(e.total_establishment) AS total_establishments,
    SUM(e.micro_firms) AS total_micro_firms,
    SUM(e.small_firms) AS total_small_firms,
    SUM(e.medium_firms) AS total_medium_firms,
    SUM(e.large_firms) AS total_large_firms 
FROM 
    establishment e 
JOIN 
    geography ge ON e.CODGEO = ge.CODGEO 
GROUP BY 
    ge.region_name;
SELECT * FROM view_total_establishments_by_region_with_size_order;

-- DROP VIEW IF EXISTS view_population_by_region_gender_order;
CREATE VIEW view_population_by_region_gender_order AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(p.total_population) DESC) AS order_number,
    ge.region_name, 
    ROUND(SUM(p.total_population), 2) AS total_population, 
    ROUND(SUM(CASE WHEN g.gender = 'male' THEN p.total_population ELSE 0 END), 2) AS total_population_male,
    ROUND(SUM(CASE WHEN g.gender = 'female' THEN p.total_population ELSE 0 END), 2) AS total_population_female
FROM population p  
JOIN geography ge ON p.CODGEO = ge.CODGEO 
JOIN gender g ON p.gender = g.gender_id
GROUP BY ge.region_name 
ORDER BY total_population DESC ;
SELECT * FROM view_population_by_region_gender_order;


-- DROP VIEW IF EXISTS view_salary_by_gender_job_region_ordered;
CREATE VIEW view_salary_by_gender_job_region_ordered AS
SELECT
    ge.region_name,
    g.gender,
    ROUND(SUM(p.total_population), 2) AS total_population,
    ROUND(AVG(s.mean_salary), 2) AS average_salary,
    ROUND(AVG(s.mean_salary_executive), 2) AS total_mean_salary_executive,
    ROUND(AVG(s.mean_salary_middlemanagement), 2) AS total_mean_salary_middlemanagement,
    ROUND(AVG(s.mean_salary_employee), 2) AS total_mean_salary_employee,
    ROUND(AVG(s.mean_salary_worker), 2) AS total_mean_salary_worker,
    ROUND(AVG(s.mean_salary_youngage), 2) AS total_mean_salary_youngage,
    ROUND(AVG(s.mean_salary_mediumage), 2) AS total_mean_salary_mediumage,
    ROUND(AVG(s.mean_salary_oldage), 2) AS total_mean_salary_oldage
FROM population p
JOIN gender g ON p.gender = g.gender_id
JOIN salary s ON p.CODGEO = s.CODGEO AND p.gender = s.gender
JOIN geography ge ON p.CODGEO = ge.CODGEO
JOIN view_population_by_region_gender_order vp ON ge.region_name = vp.region_name
GROUP BY ge.region_name, g.gender
ORDER BY 
	vp.order_number,
    ge.region_name,
    FIELD(g.gender, 'male', 'female');
SELECT * FROM view_salary_by_gender_job_region_ordered ;

-- DROP VIEW IF EXISTS view_all_population_salary_by_dep;
CREATE VIEW view_all_population_salary_by_dep AS
SELECT
    ge.code_departement,
    ge.departement_name,
    g.gender,
    ROUND(SUM(p.total_population), 2) AS total_population,
    ROUND(AVG(s.mean_salary), 2) AS average_salary,
    ROUND(SUM(CASE WHEN p.age_cat_id = '1' THEN p.total_population ELSE 0 END), 2) AS total_population_under25yo,
    ROUND(AVG(s.mean_salary_youngage), 2) AS average_salary_under25yo,
    ROUND(SUM(CASE WHEN p.age_cat_id = '2' THEN p.total_population ELSE 0 END), 2) AS total_population_25to49yo,
    ROUND(AVG(s.mean_salary_mediumage), 2) AS average_salary_25to49yo,
    ROUND(SUM(CASE WHEN p.age_cat_id = '3' THEN p.total_population ELSE 0 END), 2) AS total_population_over50yo,
    ROUND(AVG(s.mean_salary_oldage), 2) AS average_salary_over50yo,
    ROUND(SUM(CASE WHEN j.job_cat = 'executive' THEN p.total_population ELSE 0 END), 2) AS total_population_executive,
	ROUND(AVG(s.mean_salary_executive), 2) AS average_salary_executive,
    ROUND(SUM(CASE WHEN j.job_cat = 'middle_management' THEN p.total_population ELSE 0 END), 2) AS total_population_middle_management,
    ROUND(AVG(s.mean_salary_middlemanagement), 2) AS average_salary_middlemanagement,
	ROUND(SUM(CASE WHEN j.job_cat = 'employee' THEN p.total_population ELSE 0 END), 2) AS total_population_employee,
    ROUND(AVG(s.mean_salary_employee), 2) AS average_salary_employee,
    ROUND(SUM(CASE WHEN j.job_cat = 'worker' THEN p.total_population ELSE 0 END), 2) AS total_population_worker,
    ROUND(AVG(s.mean_salary_worker), 2) AS average_salary_worker
FROM population p
JOIN gender g ON p.gender = g.gender_id
JOIN job_cat j ON j.job_cat_id = p.job_cat_id
JOIN salary s ON p.CODGEO = s.CODGEO AND p.gender = s.gender
JOIN geography ge ON p.CODGEO = ge.CODGEO
GROUP BY ge.code_departement, ge.departement_name, g.gender
ORDER BY 
    ge.code_departement,
    FIELD(g.gender, 'male', 'female');
SELECT * FROM view_all_population_salary_by_dep;

-- Gender Pay Gap by Departement
CREATE VIEW view_gender_paygap_by_dep AS
SELECT 
	ge.code_departement,     
    ge.departement_name,  
    ROUND(AVG(CASE WHEN s.gender = '1' THEN s.mean_salary END),2) AS avg_salary_male,
    ROUND(AVG(CASE WHEN s.gender = '2' THEN s.mean_salary END),2) AS avg_salary_female,
    ROUND(AVG(s.mean_salary),2) AS avg_salary_all,
    ROUND(AVG(CASE WHEN s.gender = '2' THEN s.mean_salary END)-AVG(CASE WHEN s.gender = '1' THEN s.mean_salary END),2) AS gender_pay_gap 
FROM 
    salary s
JOIN geography ge ON s.CODGEO = ge.CODGEO
GROUP BY ge.code_departement, ge.departement_name
UNION 
SELECT 
    NULL AS code_departement,     
    'Total' AS departement_name,  
    ROUND(AVG(CASE WHEN s.gender = '1' THEN s.mean_salary END), 2) AS avg_salary_male,
    ROUND(AVG(CASE WHEN s.gender = '2' THEN s.mean_salary END), 2) AS avg_salary_female,
    ROUND(AVG(s.mean_salary), 2) AS avg_salary_all,
    ROUND(AVG(CASE WHEN s.gender = '2' THEN s.mean_salary END) - AVG(CASE WHEN s.gender = '1' THEN s.mean_salary END), 2) AS gender_pay_gap 
FROM 
    salary s;
SELECT * FROM view_gender_paygap_by_dep;

SELECT * FROM view_gender_paygap_by_dep;
SELECT * FROM final_project.view_gender_paygap_by_dep
order by gender_pay_gap limit 5;

SELECT * FROM final_project.view_gender_paygap_by_dep
order by gender_pay_gap desc limit 5 ;

 -- Corrélation de Pearson between population & etablishment by région 
SELECT 
    ge.code_departement,
    ge.departement_name,
    ROUND((
        COUNT(*) * SUM(p.total_population * e.total_establishment) - 
        SUM(p.total_population) * SUM(e.total_establishment)
    ) / (
        SQRT((COUNT(*) * SUM(p.total_population * p.total_population)) - (SUM(p.total_population) * SUM(p.total_population))) *
        SQRT((COUNT(*) * SUM(e.total_establishment * e.total_establishment)) - (SUM(e.total_establishment) * SUM(e.total_establishment)))
    ), 2) AS population_establishment_correlation
FROM 
    population p
JOIN 
    geography ge ON p.CODGEO = ge.CODGEO
JOIN 
    establishment e ON p.CODGEO = e.CODGEO
GROUP BY 
    ge.code_departement, ge.departement_name
ORDER BY population_establishment_correlation ASC
;

-- crée une vue pour API 
-- DROP VIEW IF EXISTS view_api_all_establishment_by_dep;
CREATE VIEW view_api_all_establishment_by_dep AS
SELECT 
    ge.code_departement,
    ge.departement_name,
    ROUND(SUM(p.total_population), 2) AS total_population, 
    SUM(e.total_establishment) AS total_establishments,
        ROUND((
        COUNT(*) * SUM(p.total_population * e.total_establishment) - 
        SUM(p.total_population) * SUM(e.total_establishment)
    ) / (
        SQRT((COUNT(*) * SUM(p.total_population * p.total_population)) - (SUM(p.total_population) * SUM(p.total_population))) *
        SQRT((COUNT(*) * SUM(e.total_establishment * e.total_establishment)) - (SUM(e.total_establishment) * SUM(e.total_establishment)))
    ), 2) AS population_establishment_correlation,
    SUM(e.micro_firms) AS total_micro_firms,
    SUM(e.small_firms) AS total_small_firms,
    SUM(e.medium_firms) AS total_medium_firms,
    SUM(e.large_firms) AS total_large_firms, 
	SUM(e.agriculture_est) AS total_agriculture_sector, 
    SUM(e.industry_est) AS total_industry_sector, 
    SUM(e.construction_est) AS total_construction_sector, 
    SUM(e.commerce_transport_est) AS total_commerce_transport_sector,
    SUM(e.public_est) AS total_public_sector
FROM 
    population p
JOIN 
    geography ge ON p.CODGEO = ge.CODGEO
JOIN 
    establishment e ON p.CODGEO = e.CODGEO
GROUP BY 
    ge.code_departement, ge.departement_name
ORDER BY ge.code_departement;
SELECT * FROM view_api_all_establishment_by_dep;

-- Pearson correlation establishment and population
  SELECT ROUND((
        COUNT(*) * SUM(p.total_population * e.total_establishment) - 
        SUM(p.total_population) * SUM(e.total_establishment)
    ) / (
        SQRT((COUNT(*) * SUM(p.total_population * p.total_population)) - (SUM(p.total_population) * SUM(p.total_population))) *
        SQRT((COUNT(*) * SUM(e.total_establishment * e.total_establishment)) - (SUM(e.total_establishment) * SUM(e.total_establishment)))
    ), 2) AS population_establishment_correlation
FROM 
    population p
JOIN 
    geography ge ON p.CODGEO = ge.CODGEO
JOIN 
    establishment e ON p.CODGEO = e.CODGEO;
    
    
select * 
from view_api_all_establishment_by_dep vapi
join view_all_population_salary_by_dep vall on vall.code_departement = vapi.code_departement;



SELECT 
    vall.code_departement,
    vall.departement_name,
    ROUND(SUM(p.total_population), 2) AS total_population,
    ROUND(AVG(pg.avg_salary_all),2) AS average_salary_all,
    ROUND(AVG(pg.avg_salary_male),2) AS average_salary_male,
    ROUND(AVG(pg.avg_salary_female),2) AS average_salary_female,
    ROUND(AVG(pg.gender_pay_gap),2) AS gender_paygap,
	ve.population_establishment_correlation,
    SUM(e.total_establishment) AS total_establishments
FROM view_all_population_salary_by_dep vall
JOIN view_gender_paygap_by_dep pg ON vall.code_departement = pg.code_departement
JOIN geography ge ON ge.code_departement = vall.code_departement
JOIN view_api_all_establishment_by_dep ve ON ve.code_departement = vall.code_departement
JOIN establishment e ON ge.CODGEO = e.CODGEO
JOIN population p ON p.CODGEO = e.CODGEO
GROUP BY vall.code_departement, vall.departement_name, ve.population_establishment_correlation
ORDER BY pg.code_departement ;

-- pour API - pop_est_correlation_and_paygap
SELECT 
    vall.code_departement,
    vall.departement_name,
    SUM(vall.total_population) AS total_population,
    ROUND(AVG(pg.avg_salary_all),2) AS average_salary_all,
    ROUND(AVG(pg.avg_salary_male),2) AS average_salary_male,
    ROUND(AVG(pg.avg_salary_female),2) AS average_salary_female,
    ROUND(AVG(pg.gender_pay_gap),2) AS gender_paygap,
	ve.population_establishment_correlation,
    SUM(e.total_establishment) AS total_establishments,
    SUM(e.micro_firms) AS total_micro_firms,
    SUM(e.small_firms) AS total_small_firms,
    SUM(e.medium_firms) AS total_medium_firms,
    SUM(e.large_firms) AS total_large_firms 
FROM view_all_population_salary_by_dep vall
JOIN view_gender_paygap_by_dep pg ON vall.code_departement = pg.code_departement
JOIN geography ge ON ge.code_departement = vall.code_departement
JOIN view_api_all_establishment_by_dep ve ON ve.code_departement = vall.code_departement
JOIN establishment e ON ge.CODGEO = e.CODGEO
GROUP BY vall.code_departement, vall.departement_name, ve.population_establishment_correlation;

select * from view_all_population_salary_by_dep;

select * from salary_all;

select *
 from view_gender_paygap_by_dep;
 
 select * from population;