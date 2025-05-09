from neo4j import GraphDatabase
import random
from dotenv import load_dotenv # Nos va a permitir leer las variables de entorno
import os

# Cargar las variables de entorno
load_dotenv()

# Aca simplemente pasamos los datos de las variables de entorno
uri = os.getenv('uri')
username = os.getenv('usernameNeo4j')
password = os.getenv('password')
driver = GraphDatabase.driver(uri, auth=(username, password))

cantidadVuelos = [3, 2, 3, 4, 1, 4, 5, 3, 2, 3, 2]

# Crear el atributo countFlies en (a:Airport)-[r:TO]->(a2:Airport)

def createCountFlies(session, cantidadVuelos):
    contador = 0  # Inicializamos el contador
    
    # Obtenemos los IDs de todas las relaciones [:TO]
    obtener_ids = ("""
        MATCH ()-[r:TO]->()
        RETURN id(r) AS rel_id
    """)

    # Ahora ejecutamos la query y lo guardamos en result
    result = session.run(obtener_ids)

    # Ahora simplemente guardamos la lista de ids
    relaciones = [record["rel_id"] for record in result]

    # Ahora obtenemos la longitud para el While
    max_relaciones = len(relaciones)

    # Iteramos con while y asignar valores aleatorios
    while contador < max_relaciones:
        # Seleccionamos un id de la relación y un valor aleatorio de la cantidad de vuelos
        rel_id = relaciones[contador]
        valor_random = random.choice(cantidadVuelos)

        # creamos la query
        query = ("""
            MATCH ()-[r]->()
            WHERE id(r) = $rel_id
            SET r.countFlies = $valor
        """)
        
        session.run(query, rel_id=rel_id, valor=valor_random)
        
        # Incrementamos el contador
        contador += 1    

# Ejecutamos el bucle para crear relaciones
with driver.session() as session:
    createCountFlies(session, cantidadVuelos)

# Cerramos la conexión al terminar
driver.close()
