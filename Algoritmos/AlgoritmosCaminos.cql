//-------------------------------------- Algoritmos de Caminos ------------------------------------------------

// Los aeropuertos que vamos a querer ver su Shortest Path van a ser:
// 1. (a:Airport{Label:"Rome"})-[:TO]->(a2:Airport{Label:"Arrecife"})
// 2. Todas las shortest path de Rome

// DELTA-STEPPING SINGLE-SOURCE SHORTEST PATHS
// PASO 1: Creamos el subgrafo
CALL gds.graph.project.cypher( 
  'fromItalySingleSource',

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
MATCH (source:Airport {Label: 'Rome'})
CALL gds.allShortestPaths.delta.write.estimate('fromItalySingleSource', {
    sourceNode: source,
    relationshipWeightProperty: 'weight',
    writeRelationshipType: 'PATH'
})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory
RETURN nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo:
MATCH (source:Airport {Label: 'Rome'})
CALL gds.allShortestPaths.delta.stream('fromItalySingleSource', {
    sourceNode: source,
    relationshipWeightProperty: 'weight',
    delta: 3.0
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    index,
    gds.util.asNode(sourceNode).Label AS sourceNodeName,
    gds.util.asNode(targetNode).Label AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).Label] AS nodeNames,
    costs,
    nodes(path) as path
ORDER BY index;

// Paso 4: Implementamos
MATCH (source:Airport {Label: 'Rome'})
CALL gds.allShortestPaths.delta.write('fromItalySingleSource', {
    sourceNode: source,
    relationshipWeightProperty: 'weight',
    writeRelationshipType: 'PATH_Rome_Undirected',
    writeNodeIds: true,
    writeCosts: true
})
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Paso 5: Probamos
MATCH (a:Airport{Label:"Rome"})-[r:PATH_Rome_Undirected]->(a2:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.Id AS ID,
    a.Label AS Ciudad,
    r.totalCost AS totalCost,
    a2.Label
ORDER BY totalCost DESC;


// DELTA-STEPPING SOURCE-TARGET SHORTEST PATHS:



// YEN’S SHORTEST PATH ALGORITHM:
