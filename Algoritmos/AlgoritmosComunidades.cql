//-------------------------------------- Algoritmos de Comunidades ------------------------------------------------

// WEAKLY CONNECTED COMPONENTS
// PASO 1: subgrafo
CALL gds.graph.project.cypher( 
  'fromItalyWCC',

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
CALL gds.wcc.write.estimate('fromItalyWCC', { writeProperty: 'communityWCCSubGraph' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.wcc.stream('fromItalyWCC')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS name, componentId
ORDER BY componentId, name;

// PASO 4: escribir atributo
CALL gds.wcc.write('fromItalyWCC', {writeProperty: 'communityWCCSubGraph'})
YIELD componentCount, componentDistribution;

// PASO 5: comprobar el atributo
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.communityWCCSubGraph as numero_de_WCC,
    COLLECT(a.Label) AS Miembros
ORDER BY numero_de_WCC DESC;


// K-1 COLORING
// PASO 1: subgrafo
CALL gds.graph.project.cypher( 
  'fromItalyK1',

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
CALL gds.k1coloring.write.estimate('fromItalyK1', { writeProperty: 'k1colorSubGraph' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.k1coloring.stream('fromItalyK1')
YIELD nodeId, color
RETURN gds.util.asNode(nodeId).name AS name, color
ORDER BY name

// PASO 4: escribir atributo
CALL gds.k1coloring.write('fromItalyK1', {writeProperty:'k1colorSubGraph'})
YIELD nodeCount, colorCount, ranIterations, didConverge;

// PASO 5: Sumarle +1 al color
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
SET a.k1colorSubGraph = a.k1colorSubGraph + 1
RETURN a.k1colorSubGraph as numero_de_comunidad,
    COLLECT(a.Label) AS Miembros
ORDER BY numero_de_comunidad DESC;

// PASO 6: comprobar el atributo
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.k1colorSubGraph as numero_de_comunidad,
    COLLECT(a.Label) AS Miembros
ORDER BY numero_de_comunidad DESC;



// LOUVAIN MODULARITY
// PASO 1: subgrafo
CALL gds.graph.project.cypher( 
  'fromItalyLM',

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
CALL gds.louvain.write.estimate('fromItalyLM', { writeProperty: 'louvainSubGraph' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// PASO 3: Aplicamos el algoritmo
CALL gds.louvain.stream('fromItalyLM')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).name AS name, communityId
ORDER BY name ASC;

// PASO 4: escribir atributo
CALL gds.louvain.write('fromItalyLM', {writeProperty: 'louvainSubGraph'})
YIELD communityCount, modularity, modularities;

// PASO 5: comprobar el atributo
MATCH (a:Airport)
WHERE a.country = "Italy" OR a.country = "Spain"
RETURN a.louvainSubGraph as numero_de_comunidad,
    COLLECT(a.Label) AS Miembros
ORDER BY numero_de_comunidad DESC;