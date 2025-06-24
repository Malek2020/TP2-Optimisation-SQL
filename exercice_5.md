# Exercice 5

## 5.1 – Requête de recherche par identifiant

Dans cet exercice, on va chercher un film précis grâce à son identifiant (dans ce cas : tt0111161).

la requête avec EXPLAIN ANALYZE :

```sql
EXPLAIN ANALYZE
SELECT b.primary_title, r.average_rating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.tconst = 'tt0111161';
```

## 5.2 – Analyse du plan

### 1) Algorithme de jointure utilisé

PostgreSQL a utilisé une Nested Loop Join dans ce cas.  
Ce qui est logique car la condition tconst = 'tt0111161' est très restrictive (une seule ligne, donc pas besoin de parcourir toute la table)

### 2) Utilisation de l’index sur tconst


-Les deux tables ont des index sur tconst (généralement, c’est même leur clé primaire).  
du coup, PostgreSQL utilise Index Scan pour accéder rapidement à la ligne


### 3) Comparaison du temps d’exécution

-Le temps d’exécution était très faible (environ 0.3 ms)

Comparé aux requêtes précédentes (dans les 700–1200 ms voire plus), ici c’est instantané.

### 4) Pourquoi c’est si rapide ?

-La requête concerne une seule ligne → pas de parcours massif

-Les index sont parfaitement adaptés (tconst est unique)

-Pas de tri, pas de calcul, pas de gros filtre





