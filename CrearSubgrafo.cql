// crear distancia invertida
MATCH (:Airport) -[r:TO]- (:Airport)
SET r.inverseDistance = 1/r.distance;

// crear subgrafo
CALL gds.graph.project.cypher( 
  'fromSpainToItaly',

  'MATCH (n:Airport) 
   WHERE n.country IN ["Spain", "Italy"]  
   RETURN id(n) AS id, 
          CASE WHEN n.latitude IS NOT NULL THEN toFloat(n.latitude) ELSE NULL END AS latitude,
          CASE WHEN n.longitude IS NOT NULL THEN toFloat(n.longitude) ELSE NULL END AS longitude',

  'MATCH (a:Airport)-[r:TO]->(b:Airport) 
   WHERE a.country = "Spain" AND b.country = "Italy"
   RETURN id(a) AS source, id(b) AS target, r.inverseDistance AS weight'
);

// analizar subgrafo

// ver aeropuertos
CALL gds.graph.nodeProperty.stream('fromSpainToItaly', 'latitude')
YIELD nodeId, propertyValue AS latitude
RETURN 
  gds.util.asNode(nodeId).Label AS name,
  gds.util.asNode(nodeId).country AS country,
  latitude;

// ver paises
CALL gds.graph.nodeProperty.stream('fromSpainToItaly', 'latitude')
YIELD nodeId
WITH gds.util.asNode(nodeId).country AS country, count(*) AS numAirports
RETURN country;

// ver ditancias mas cortas
CALL gds.graph.relationshipProperty.stream('fromSpainToItaly', 'weight')
YIELD sourceNodeId, targetNodeId, propertyValue AS weight
RETURN 
  gds.util.asNode(sourceNodeId).Label AS from,
  gds.util.asNode(targetNodeId).Label AS to,
  weight
ORDER BY weight DESC;