# Exercice 3: Jointures et filtres

## 3.1 Jointure avec filtres

Écrivez une requête avec EXPLAIN ANALYZE qui joint les tables title_basics et title_ratings pour trouver
le titre et la note des films sortis en 1994 ayant une note moyenne supérieure à 8.5

```sql
EXPLAIN ANALYZE SELECT primary_title, average_rating
FROM title_basics a JOIN title_ratings b ON a.tconst = b.tconst
WHERE start_year = 1994 AND average_rating > 8.5;
```

## 3.2 Analyse du plan de jointure
1. Quel algorithme de jointure est utilisé ?

> Hash Join

2. Comment l'index sur start_year est-il utilisé ?

> L'index sur start_year est utilisé dans un Index Scan: ***-> Bitmap Index Scan on idx_start_year  (cost=0.00..653.29 rows=59848 width=0) (actual time=2.973..2.973 rows=68964 loops=1) Index Cond: (start_year = 1994)***

3. Comment est traitée la condition sur average_rating ?

> La condition sur average_rating est traitée comme un filtre de scan séquentiel: ***Filter: (start_year = 1994)***

4. Pourquoi PostgreSQL utilise-t-il le parallélisme ?

> PostgreSQL utilise le parallélisme pour améliorer les performances des requêtes, notamment ici sur le scan séquentiel et la jointure. Cela permet de segmenter la table en plusieurs en plusieurs morceaux traités simultanément.

## 3.3 Indexation de la seconde condition
Créez un index sur la colonne average_rating de la table title_ratings.

```sql
CREATE INDEX idx_average_rating
ON title_ratings(average_rating);
```

## 3.4 Analyse après indexation
Exécutez à nouveau la requête de l'étape 3.1 et observez les différences.

## 3.5 Analyse de l'impact
1. L'algorithme de jointure a-t-il changé?

> Non, l'algorithme est toujours **Hash Join**

2. Comment l'index sur average_rating est-il utilisé?

> L'index sur average_rating est désormais utilisé lors du scan à la place du scan séquentiel précédent: ***Bitmap Index Scan on idx_average_rating  (cost=0.00..2737.38 rows=147860 width=0) (actual time=6.932..6.933 rows=151388 loops=1)***

3. Le temps d'exécution s'est-il amélioré? Pourquoi?

> Oui, le temps d'exécution s'est amélioré (de **1200ms** à **344ms**) car le scan séquentiel n'a plus lieu. À la place, un INDEX SCAN est réalisé sur le nouvel index sur start_year, ce qui est beaucoup plus rapide

4. Pourquoi PostgreSQL abandonne-t-il le parallélisme?
