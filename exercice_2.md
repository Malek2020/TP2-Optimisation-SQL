# Exercice 2 

## 2.1 – Requête avec conditions multiples

```sql
EXPLAIN ANALYZE
SELECT *
FROM title_basics
WHERE title_type = 'movie'
  AND start_year = 1950;
```

## 2.2 – Analyse du plan d'exécution

**Stratégie utilisée pour start_year** :  
  PostgreSQL utilise un Bitmap Index Scan sur idx_start_year suivi d’un Bitmap Heap Scan.

**Filtre sur title_type** :  
  Appliqué après l'accès aux lignes correspondant à start_year = 1950, donc encore effectué dans le tas

**Lignes filtrées** :

  -Après start_year = 1950 : ~15 000 lignes
  
  -Après title_type = 'movie' : ~6 800 lignes

**Limites de l’index actuel** :

  -L’index start_year ne couvre qu’une condition.

  -PostgreSQL doit accéder au tas (heap) pour vérifier title_type

## 2.3 – Création d’un index composite

```sql
CREATE INDEX idx_year_type ON title_basics(start_year, title_type);
```

## 2.4 – Analyse après index composite

```sql
EXPLAIN ANALYZE
SELECT *
FROM title_basics
WHERE title_type = 'movie'
  AND start_year = 1950;
```

 -PostgreSQL utilise maintenant un **Bitmap Index Scan** sur l’index composite idx_year_type

 -Les deux filtres sont combinés dans l’index → moins de lectures disque → gain de performance

## 2.5 – Impact du nombre de colonnes

```sql
EXPLAIN ANALYZE
SELECT tconst, primary_title, start_year, title_type
FROM title_basics
WHERE title_type = 'movie'
  AND start_year = 1950;
```

**Temps d’exécution** : baisse d’environ 200–300 ms.

**Pourquoi ?**

-Moins de colonnes à charger en mémoire.

-Moins de données à transmettre en sortie.

**Optimisation moins marquée qu’en Exercice 1** :


  


**Covering index (index couvrant)** :
  Utile si toutes les colonnes du SELECT sont dans l’index.
  → Exemple :
  ```sql
  CREATE INDEX idx_covering ON title_basics(start_year, title_type, tconst, primary_title);
  ```

## 2.6 – Analyse de l'amélioration globale

**Gain de temps d’exécution** :
  
  -Avant : ~1 400 ms
  
  -Après : ~730 ms

**Impact de l’index composite** :

-PostgreSQL utilise directement les deux conditions.

-Moins de blocs lus dans le heap → gain important.

**Pourquoi moins de Heap Blocks ?**

-Moins de lignes candidates à lire depuis le disque.

-Moins de post-filtrage nécessaire.




