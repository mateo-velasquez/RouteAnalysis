//-------------------------------------- Algoritmos de Centralidad ---------------------------------------

// DEGREE CENTRALITY
// PASO 1: Creamos el subgrafo
CALL gds.graph.project.cypher( 
  'fromItalyDEG',

  'MATCH (n:Airport) 
   WHERE n.country IN ["Spain", "Italy"]  
   RETURN id(n) AS id, 
          CASE WHEN n.latitude IS NOT NULL THEN toFloat(n.latitude) ELSE NULL END AS latitude,
          CASE WHEN n.longitude IS NOT NULL THEN toFloat(n.longitude) ELSE NULL END AS longitude',

  'MATCH (a:Airport)-[r:TO]->(b:Airport) 
   WHERE 
     (a.country = "Spain" AND b.country = "Italy") OR
     (a.country = "Italy" AND b.country = "Spain") OR
     (a.country = "Italy" AND b.country = "Italy")
   RETURN id(a) AS source, id(b) AS target, r.countFlies AS weight'
);

// Paso 2: Calculo la memoria necesaria:
CALL gds.degree.write.estimate(
    'fromItalyDEG', {writeProperty: 'degreeSubGraph'})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo:
CALL gds.degree.stream(
    'fromItalyDEG'
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS id, gds.util.asNode(nodeId).name AS Movie, score
ORDER BY score DESC, Movie ASC;

// Paso 4: Implementamos
CALL gds.degree.write('fromItalyDEG', { writeProperty: 'degreeSubGraph' })
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore, centralityDistribution.mean AS meanScore,
centralityDistribution.max AS maxScore, nodePropertiesWritten;

// Paso 5: Probamos
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS Ciudad,
    a.degreeSubGraph AS Grado
ORDER BY Grado DESC;


// CLOSENESS CENTRALITY
// PASO 1: Creamos el subgrafo
CALL gds.graph.project.cypher( 
  'fromItalyCC',

  'MATCH (n:Airport) 
   WHERE n.country IN ["Spain", "Italy"]  
   RETURN id(n) AS id, 
          CASE WHEN n.latitude IS NOT NULL THEN toFloat(n.latitude) ELSE NULL END AS latitude,
          CASE WHEN n.longitude IS NOT NULL THEN toFloat(n.longitude) ELSE NULL END AS longitude',

  'MATCH (a:Airport)-[r:TO]->(b:Airport) 
   WHERE 
     (a.country = "Spain" AND b.country = "Italy") OR
     (a.country = "Italy" AND b.country = "Spain") OR
     (a.country = "Italy" AND b.country = "Italy")
   RETURN id(a) AS source, id(b) AS target, r.countFlies AS weight'
);

// PASO 2: calcular la memoria
CALL gds.closeness.write.estimate(
    'fromItalyCC', { writeProperty: 'closenessSubGraph' }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.closeness.stream(
    'fromItalyCC'
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS Name, score
ORDER BY score DESC, Name ASC;

// PASO 4: añadir el atributo
CALL gds.closeness.write('fromItalyCC', {writeProperty: 'closenessSubGraph'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore,
        centralityDistribution.max AS maxScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;

// PASO 5: Verificar
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS Ciudad,
    a.closenessSubGraph AS closenessSubGraph
ORDER BY closenessSubGraph DESC;


// BETWEENNESS CENTRALITY:
// PASO 1:
CALL gds.graph.project.cypher( 
  'fromItalyBC',

  'MATCH (n:Airport) 
   WHERE n.country IN ["Spain", "Italy"]  
   RETURN id(n) AS id, 
          CASE WHEN n.latitude IS NOT NULL THEN toFloat(n.latitude) ELSE NULL END AS latitude,
          CASE WHEN n.longitude IS NOT NULL THEN toFloat(n.longitude) ELSE NULL END AS longitude',

  'MATCH (a:Airport)-[r:TO]->(b:Airport) 
   WHERE 
     (a.country = "Spain" AND b.country = "Italy") OR
     (a.country = "Italy" AND b.country = "Spain") OR
     (a.country = "Italy" AND b.country = "Italy")
   RETURN id(a) AS source, id(b) AS target, r.countFlies AS weight'
);

// PASO 2: calcular la memoria
CALL gds.betweenness.write.estimate(
    'fromItalyBC', {writeProperty: 'betweennessSubGraph'})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.betweenness.stream('fromItalyBC')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC;

// PASO 4: Escribimos el resultado como un atributo extra en cada nodo
CALL gds.betweenness.write('fromItalyBC', {writeProperty: "betweennessSubGraph"})
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimunScore,
        centralityDistribution.mean AS meanScore,
        centralityDistribution.max AS maxScore,
        nodePropertiesWritten;

// PASO 5: Verificar
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS Ciudad,
    a.betweennessSubGraph AS betweennessSubGraph
ORDER BY betweennessSubGraph DESC; 


// PAGERANK:
//PASO 1: Creamos el subgrafo:
CALL gds.graph.project.cypher( 
  'fromItalyPR',

  'MATCH (n:Airport) 
   WHERE n.country IN ["Spain", "Italy"]  
   RETURN id(n) AS id, 
          CASE WHEN n.latitude IS NOT NULL THEN toFloat(n.latitude) ELSE NULL END AS latitude,
          CASE WHEN n.longitude IS NOT NULL THEN toFloat(n.longitude) ELSE NULL END AS longitude',

  'MATCH (a:Airport)-[r:TO]->(b:Airport) 
   WHERE 
     (a.country = "Spain" AND b.country = "Italy") OR
     (a.country = "Italy" AND b.country = "Spain") OR
     (a.country = "Italy" AND b.country = "Italy")
   RETURN id(a) AS source, id(b) AS target, r.countFlies AS weight'
);

// PASO 2: calcular la memoria
// Aca estamos calculando el pageRank
CALL gds.pageRank.write.estimate(
    'fromItalyPR', {
        writeProperty: 'pagerankSubGraph', 
        maxIterations: 20,
        dampingFactor: 0.85}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.pageRank.stream(
    'fromItalyPR'
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS Name, score
ORDER BY score DESC, Name ASC;

// PASO 4: añadir el atributo
CALL gds.pageRank.write(
    'fromItalyPR',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pagerankSubGraph'
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Paso 5: Verificar
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS Ciudad,
    a.pagerankSubGraph AS pagerankSubGraph
ORDER BY pagerankSubGraph DESC;