// --------------------------------------------- Análisis Básico -----------------------------------------------------//

// Preguntas:

// 1. ¿Cómo es el esquema general del grafo?
CALL db.schema.visualization;

// 2. ¿Cuáles son las propiedades de los nodos?
CALL db.schema.nodeTypeProperties;

// 3. ¿Cuáles son las propiedades de las relaciones?
CALL db.schema.relTypeProperties;

// 4. ¿Cuántos Airport hay en "Italy"?
MATCH (a:Airport{country:"Italy"})
RETURN COUNT(a) AS Total_Airport_In_Italy;

// 5. ¿Cuántos Airport hay en "Spain"?
MATCH (a:Airport{country:"Spain"})
RETURN COUNT(a) AS Total_Airport_In_Spain;

// 6. ¿Cuáles son las rutas entre "Italy" y "Spain" que tiene mayor frecuencia de vuelo?
MATCH (:Airport {country: "Italy"})-[r:TO]-(:Airport {country: "Spain"})
WITH MAX(r.countFlies) AS frecuenciaMax

MATCH (a:Airport {country: "Italy"})-[r:TO]-(a2:Airport {country: "Spain"})
WHERE r.countFlies = frecuenciaMax
RETURN a.name AS aeropuerto_origen, a2.name AS aeropuerto_destino, r.countFlies AS frecuencia;

// 7. ¿Cuáles rutas de vuelo hay entre "Italy" y "Spain"?
MATCH (a:Airport {country: 'Italy'})-[r:TO]-(a2:Airport {country: 'Spain'})
WHERE a.Label <> a2.Label // para diferentes aeropuertos
RETURN a, r, a2

// 8. ¿Cuáles son los Airport de "Italy" que no tienen vuelos a "Spain"?
MATCH (a:Airport{country:"Italy"})-[:TO]->(a2:Airport)
WHERE a2.country <> "Spain"
RETURN DISTINCT a.Label AS Airport;

// 9. ¿Cuáles son los Airport de "Spain" que no tienen vuelos a "Italy"?
MATCH (a:Airport{country:"Spain"})-[:TO]->(a2:Airport)
WHERE a2.country <> "Italy"
RETURN DISTINCT a.Label AS Airport;

// 10. ¿Cómo es el esquema general del subgrafo?
MATCH (a:Airport)-[r:TO]->(b:Airport)
WHERE a.country = "Spain" AND b.country = "Italy"
RETURN a, r, b;

// 11. ¿Cuáles son los 5 Airport de "Italy" con más rutas de vuelo a "Spain"?
MATCH (a:Airport{country:"Italy"})-[r:TO]->(a2:Airport{country:"Spain"})
WITH a.Id AS ID,
    a.Label AS Ciudad,
    COUNT(r) AS total_rutas
RETURN ID, Ciudad, total_rutas
ORDER BY total_rutas DESC
LIMIT 5;

// 12. ¿Cuáles son los 5 Airport de "Spain" con más rutas de vuelo a "Italy"?
MATCH (a:Airport{country:"Spain"})-[r:TO]->(a2:Airport{country:"Italy"})
WITH a.Id AS ID,
    a.Label AS Ciudad,
    COUNT(r) AS total_rutas
RETURN ID, Ciudad, total_rutas
ORDER BY total_rutas DESC
LIMIT 5;

// 13. ¿Cuáles son los Airport de "Italy" con rutas de vuelo dentro de "Italy"?
MATCH (a:Airport {country: 'Italy'})-[r:TO]->(a2:Airport {country: 'Italy'})
WHERE a.Label <> a2.Label // para diferentes aeropuertos
RETURN a, r, a2


// 14. ¿Cuál es la densidad del grafo?


// 15. ¿Cuál es el diametro del grafo?




