# Exercice 4: Agrégation et tri

## 4.1 Requête complexe

Écrivez une requête avec EXPLAIN ANALYZE qui calcule, pour chaque année entre 1990 et 2000, le
nombre de films et leur note moyenne, puis trie les résultats par note moyenne décroissante.

```sql
EXPLAIN ANALYZE SELECT start_year, COUNT(*), AVG(average_rating) AS year_average
FROM title_basics a JOIN title_ratings b ON a.tconst = b.tconst
WHERE start_year BETWEEN 1990 AND 2000
GROUP BY start_year
ORDER BY year_average DESC;
```

## 4.2 Analyse du plan complexe

### 1. Identifiez les différentes étapes du plan (scan, hash, agrégation, tri)

> INDEX SCAN sur start_year ***->  Bitmap Index Scan on idx_start_year  (cost=0.00..11614.03 rows=867360 width=0) (actual time=41.731..41.731 rows=859264 loops=1) Index Cond: ((start_year >= 1990) AND (start_year <= 2000))***

> Hash JOIN ***->  Parallel Hash Join  (cost=252510.48..279126.23 rows=48702 width=10) (actual time=441.796..498.402 rows=51998 loops=3)***

> Seq SCAN sur la table title_ratings ***-> Parallel Seq Scan on title_ratings b  (cost=0.00..16685.11 rows=658911 width=16) (actual time=0.035..34.005 rows=527129 loops=3)***

> Aggrégation ***->  Partial HashAggregate  (cost=279491.50..279493.15 rows=132 width=44) (actual time=503.122..503.159 rows=11 loops=3) ->  Finalize GroupAggregate  (cost=280497.82..280532.91 rows=132 width=44) (actual time=520.510..527.329 rows=11 loops=1)***

> Tri ***->  Sort  (cost=279497.80..279498.13 rows=132 width=44) (actual time=503.141..503.177 rows=11 loops=3) Sort Key: a.start_year" Sort Method: quicksort  Memory: 26kB" Worker 0:  Sort Method: quicksort  Memory: 26kB" Worker 1:  Sort Method: quicksort  Memory: 26kB"***

### 2. Pourquoi l'agrégation est-elle réalisée en deux phases ("Partial" puis "Finalize")?

> Car PostgreSQL utilise le parallélisme. Dans la phase "Partial", des workers indépendants travaillent sur des segments de la table avant qu'un processus leader combine tous les résultats partiels dans la phase "Finalize" pour obtenir le résultat final. Ceci permet d'améliorer les performances.

### 3. Comment sont utilisés les index existants?
 
> L'index sur start_year est utilisé lors du scan (INDEX SCAN) pour **traiter la condition du WHERE** (WHERE start_year BETWEEN 1990 AND 2000). L'index sur average_rating **n'est pas utilisé**.

### 4. Le tri final est-il coûteux? Pourquoi?

Oui le tri final est coûteux.

## 4.3 Indexation des colonnes de jointure

Créez des index sur les colonnes tconst des deux tables (title_basics et title_ratings).

```sql
CREATE INDEX idx_title_basics_tconst ON title_basics(tconst);
CREATE INDEX idx_title_ratings_tconst ON title_ratings(tconst);
```

## 4.4 Analyse après indexation

Exécutez à nouveau la requête de l'étape 4.1 et observez les résultats.

## 4.5 Analyse des résultats

### 1. Les index de jointure sont-ils utilisés? Pourquoi?

> Les index sur tconst **ne sont pas utilisés** car dans le plan d'execution choisi maintient le Hash Join, et donc les deux tables sont scannées séquentiellement plutôt que d'utiliser des accès index pour la jointure;

### 2. Pourquoi le plan d'exécution reste-t-il pratiquement identique?

> Le plan reste identique car les index de jointure n'apportent aucune plus-value ou gain de performance sur les opérations réalisées dans cette requête. Le Hash Join reste la stratégie de jointure optimale.

### 3. Dans quels cas les index de jointure seraient-ils plus efficaces?

* Sélectivité élevée du filtre (par exemple un filtre sur une seule année, ou un sur une période plus courte)
* Différence de taille importante entre les tables
* Jointures sur des colonnes non-clés