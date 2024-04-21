import json
import math
import os
from collections import defaultdict, Counter

from flask import Flask, request, abort, jsonify
from flask_swagger_ui import get_swaggerui_blueprint

import pymysql
pw_raw = os.getenv('mysql_stef')

swaggerui_blueprint = get_swaggerui_blueprint(
    base_url='/docs',
    api_url='/static/fp_myAPI_swagger.yml',
)
app = Flask(__name__)
app.register_blueprint(swaggerui_blueprint)

def remove_null_fields(obj):
    return {k:v for k, v in obj.items() if v is not None}


@app.route("/population_salary/<code_departement>")

def population_salary_by_dep(code_departement):
    db_conn = pymysql.connect(host="localhost"
                            , user="root"
                            ,  password=pw_raw
                            , database="final_project",
                            cursorclass=pymysql.cursors.DictCursor)
    with db_conn.cursor() as cursor:
        cursor.execute("""
                    SELECT * 
                    FROM view_all_population_salary_by_dep 
                    WHERE code_departement = %s
                    """,
                    (code_departement,)             
                        )
        population_salary_by_dep = cursor.fetchall()

        # Vérifier si des données ont été trouvées
        if not population_salary_by_dep:
            abort(404)  # Aucun département trouvé, retourner une erreur 404

    print("Population salary by department:", population_salary_by_dep)

    with db_conn.cursor() as cursor:
        cursor.execute("""
                SELECT * 
                FROM view_api_all_establishment_by_dep 
                WHERE code_departement = %s
                """,
                (code_departement,)             
            )
        establishment_results = cursor.fetchall()
    
    db_conn.close() 

    print("Establishment results:", establishment_results)  # Ajoutez cette ligne pour afficher les résultats de la deuxième requête
    
    # Créer un dictionnaire pour stocker les deux tableaux de résultats
    results = {
        "population_salary": population_salary_by_dep,
        "establishment": establishment_results
    }
    return jsonify(results)


@app.route("/population_salary")
def population_salary():

    db_conn = pymysql.connect(host="localhost", 
                            user="root",
                            password='1Azertyuiop@', 
                            database="final_project",
                            cursorclass=pymysql.cursors.DictCursor)

    
    with db_conn.cursor() as cursor:
        cursor.execute(""" 
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
                        ORDER BY pg.code_departement 
                        LIMIT %s
                        OFFSET %s
        """, )
        population_salary = cursor.fetchall()


    db_conn.close()
    return population_salary
    

