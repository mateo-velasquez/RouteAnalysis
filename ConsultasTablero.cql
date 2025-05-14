// ------------------------------------------- Consultas Tablero ---------------------------------------------------//

// 1. ¿Cuál es la cantidad de vuelos totales?
MATCH (a:Airport)-[r:TO]->(b:Airport)
RETURN sum(r.countFlies) AS total_vuelos;

// 2. ¿Cuál es la cantidad de rutas únicas (entre dos vuelos) en la base de datos?
MATCH (a:Airport)-[r:TO]->(b:Airport)
WHERE a.Label <> b.Label
RETURN count(r) AS total_rutas;

// 3. ¿Cuántos Airport hay en "Italy"?
MATCH (a:Airport{country:"Italy"})
RETURN COUNT(a) AS Total_Airport_In_Italy;

// 4. ¿Cuántos Airport hay en "Spain"?
MATCH (a:Airport{country:"Spain"})
RETURN COUNT(a) AS Total_Airport_In_Spain;

// 5. ¿Cuáles son los vuelos de un Airport filtrado?
MATCH (a:Airport)-[r:TO]-(a2:Airport)
WHERE a.Label <> a2.Label AND a.Label = $neodash_airport_label
RETURN a, r, a2;

// 6. ¿Cuáles son las rutas entre "Italy" y "Spain" que tiene mayor frecuencia de vuelo?
MATCH (:Airport {country: "Italy"})-[r:TO]-(:Airport {country: "Spain"})
WITH MAX(r.countFlies) AS frecuenciaMax

MATCH (a:Airport {country: "Italy"})-[r:TO]-(a2:Airport {country: "Spain"})
WHERE r.countFlies = frecuenciaMax
RETURN a.Label AS aeropuerto_origen, a2.Label AS aeropuerto_destino, r.countFlies AS frecuencia;

// 7. ¿Cuántas rutas de vuelo hay entre "Italy" y "Spain"?
MATCH (a:Airport {country: 'Italy'})-[r:TO]-(a2:Airport {country: 'Spain'})
WHERE a.Label <> a2.Label // para diferentes aeropuertos
RETURN a, r, a2;

// 8. ¿Cuáles son los Airport de "Italy" que no tienen vuelos a "Spain"?
MATCH (a:Airport{country:"Italy"})-[:TO]->(a2:Airport)
WHERE a2.country <> "Spain"
RETURN DISTINCT a.Label AS Airport;

// 9. ¿Cuáles son los Airport de "Spain" que no tienen vuelos a "Italy"?
MATCH (a:Airport{country:"Spain"})-[:TO]->(a2:Airport)
WHERE a2.country <> "Italy"
RETURN DISTINCT a.Label AS Airport;

// 10. ¿Cuáles son los 5 Airport de "Italy" con más rutas de vuelo a "Spain"?
MATCH (a:Airport{country:"Italy"})-[r:TO]->(a2:Airport{country:"Spain"})
WITH a.Id AS ID,
    a.Label AS Ciudad,
    COUNT(r) AS total_rutas
RETURN ID, Ciudad, total_rutas
ORDER BY total_rutas DESC
LIMIT 5;

// 11. ¿Cuáles son los 3 aeropuertos más relevantes de Italia en términos de conectividad y centralidad estructural?
MATCH (a:Airport {country: "Italy"})
RETURN a.Id AS ID, a.Label AS airport, a.degreeSubGraph AS degree, a.closenessSubGraph AS closeness, a.pagerankSubGraph as pageRank
ORDER BY degree DESC
LIMIT 3;

// 12. ¿Qué aeropuertos italianos actúan como puentes estratégicos entre diferentes regiones o países?
MATCH (a:Airport {country: "Italy"})
RETURN a.Id AS ID, a.Label AS airport, a.betweennessSubGraph as betweenness
ORDER BY betweenness DESC
LIMIT 3;

// 13. ¿Cuál es el camino más corto —en términos de distancia— entre dos aeropuertos italianos específicos?
MATCH (a:Airport{Label: 'Bolzano'})-[r:PATH_Und_Bolzano_to_Perugia]->(a2:Airport {Label: 'Perugia'})
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS Ciudad,
    r.totalCost AS totalDistance,
    a2.Label;

// 14. ¿Qué rutas conectan de Roma a Italia o España con el menor costo?
MATCH (a:Airport{Label:"Rome"})-[r:PATH_Rome_Undirected]->(a2:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS aeropuertoOrigen,
    r.totalCost AS totalCost,
    a2.Label AS aeropuertoDestino
ORDER BY totalCost ASC;

// 15. ¿Cuáles son las k rutas más cortas posibles entre dos aeropuertos y qué diferencias estructurales presentan entre ellas?
MATCH (a:Airport{Label: 'Bolzano'})-[r:PATH_Yens_k3_Und_Bolzano_to_Perugia]->(a2:Airport {Label: 'Perugia'})
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Label AS aeropuertoOrigen,
    r.totalCost AS totalDistancia,
    a2.Label AS aeropuertoDestino,
    r.nodeIds as nodeIds
ORDER BY totalDistancia ASC;

// 16. ¿Desde qué aeropuerto italiano se pueden alcanzar más destinos de España con la menor distancia total recorrida?
MATCH (a:Airport)-[r:PATH_Italy_Undirected]->(a2:Airport)
WHERE a.country = "Italy" AND a2.country = "Spain"
WITH a, COLLECT(a2.Label) AS destinosEspañoles,
     COUNT(DISTINCT a2) AS totalDestinos,
     SUM(r.totalCost) AS sumaDistancias
RETURN 
    a.Id AS ID,
    a.Label AS aeropuertoOrigen,
    totalDestinos,
    sumaDistancias,
    destinosEspañoles
ORDER BY totalDestinos DESC, sumaDistancias ASC
LIMIT 5;