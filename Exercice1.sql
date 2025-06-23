-- 1.1 Première analyse
EXPLAIN ANALYZE
SELECT *
FROM title_basics
WHERE start_year = 2020;
--1. Quelle stratégie PostgreSQL utilise-t-il ?
--PostgreSQL utilise un Parallel Seq Scan ( Resultat : Parallel Seq Scan on title_basics)

--2. Combien de lignes sont retournées ?
-- Résultat obtenue :rows=440009

--3. Combien de lignes sont examinées puis rejetées ?
-- Résultat obtenue : Rows Removed by Filter: 3,764,950

-- 4. Quel est le temps d’exécution total ?
-- Résultat obtenue :Execution Time: 3880.430 ms


-- 1. Pourquoi PostgreSQL utilise-t-il un Parallel Sequential Scan? 
-- La table title_basics contient plusieurs données 

-- 2. La parallélisation est-elle justifiée ici? Pourquoi?
-- PostgreSQL a lancé 2 workers en plus du processus principal 
-- resultat obtenue :
-- Workers Planned: 2
-- Workers Launched: 2
-- cette repartition réduit le temps global de lecture

-- 3. Que représente la valeur "Rows Removed by Filter"?
-- Resultats obtenue : Rows Removed by Filter: 3,764,950
-- 3,764,950 ce sont les lignes rejetées après application du filtre


-- 1.3 – Création d’un index
CREATE INDEX idx_start_year ON title_basics(start_year);


--1.4 – Analyse après indexation
EXPLAIN ANALYZE
SELECT *
FROM title_basics
WHERE start_year = 2020;

--1.5 – Impact du nombre de colonnes
EXPLAIN ANALYZE
SELECT tconst, primary_title, start_year
FROM title_basics
WHERE start_year = 2020;

-- Le temps d'exécution a-t-il changé? Pourquoi?
-- oui le temps a diminuer puisqu'on a selectionnée que 3 colonnes au lieu de toutes les colonnes (resultats obtenues pour 3 colonnes : 1 236 ms alors que quand c'était * on a 3 672 ms)

-- Le plan d'exécution est-il différent?
-- non

-- Pourquoi la sélection de moins de colonnes peut-elle améliorer les performances?
-- BDD n'a pas besoin de lire toutes les données de chaque ligne
-- Moins de charge sur le CPU
-- pour avoir une meiller performance vaux mieux selectionner les lignes necessaires 

--1.6 
-- 1. Quelle nouvelle stratégie PostgreSQL utilise-t-il maintenant?
Parallel Seq Scan on title_basics

--2. Le temps d'exécution s'est-il amélioré? De combien?
--  Oui, fortement.
--Avant : 3672 ms
--Après : 1236 ms
-- on ne  sélectionnes plus toutes les colonnes , donc : moins de données à lire en mémoire,  moins de données à transférer

--3. Que signifie "Bitmap Heap Scan" et "Bitmap Index Scan"?
-- Bitmap Index Scan :	PostgreSQL utilise l’index pour marquer les emplacements (TIDs) des lignes qui satisfont une condition
-- Bitmap Heap Scan	: il va chercher dans la table (heap) les vraies lignes à partir de ces TIDs

-- 4. Pourquoi l'amélioration n'est-elle pas plus importante?
-- Trop de lignes concernées + index non utilisé