// Para pasar en el informe: Vamos a hacer los vuelos desde Italia hasta España, dónde vamos a hacer los vuelos del interior Italia

// Consulta para ver los vuelos entre el mismo país
MATCH (a:Airport)-[:TO]->(a2:Airport)
WHERE a.country = a2.country
RETURN a.country, a2.country, COUNT(a2.country) AS total
ORDER BY total DESC

// Consulta para ver los vuelos entre distintos paises
MATCH (a:Airport)-[:TO]->(a2:Airport)
WHERE a.country <> a2.country
RETURN a.country, a2.country, COUNT(a2.country) AS total
ORDER BY total DESC

// Se eligieron los paises de Italia y España

// Creamos el subgrafo
CALL gds.graph.project(
    'ItalyAndSpain',
    'Airport',
    {TO:
    {
        orientation: 'NATURAL',
        Properties: 'distance'
    }}
);

// Supuestamente esto sirve para filtrar en los algoritmos:
CALL gds.pageRank.stream('ItalyAndSpain', {
  nodeFilter: 'Airport.country IN ["Italy", "Spain"]'
})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS airport, score
ORDER BY score DESC;


// Muestra el subgrafo completo
// Vuelos nacionales de Italia <-> Italia
MATCH (a:Airport {country: 'Italy'})-[r:TO]->(a2:Airport {country: 'Italy'})
WHERE a.Label <> a2.Label // para diferentes aeropuertos
RETURN a, r, a2

// Vuelos internacioles de Italia <-> España
MATCH (a:Airport {country: 'Italy'})-[r:TO]-(a2:Airport {country: 'Spain'})
WHERE a.Label <> a2.Label // para diferentes aeropuertos
RETURN a, r, a2

// Conocer aeropuertos que no van de Italia <-> España
MATCH (a:Airport {country: 'Italy'})-[:TO]->(a2:Airport)
WHERE a.country <> a2.country AND a2.country <> 'Spain'
RETURN a.Id, COUNT(a2.country) AS total
ORDER BY total DESC



