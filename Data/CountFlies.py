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

cantidadVuelos = [1, 2, 3, 4, 5]



