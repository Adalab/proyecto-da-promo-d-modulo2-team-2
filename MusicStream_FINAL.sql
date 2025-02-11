# Proyecto Music Stream

## Fase 3: Muestras de consultas en MySQLWorkbench

USE MusicStream;

SELECT * FROM Spotify;
SELECT * FROM LastFM; 


 -- Géneros musicales más populares según el género:
 
 /* 
 Esta consulta supuso un reto porque comprobamos que en LastFM había varios registros para el mismo artista y
 en Spotify había varios géneros para el mismo artista. Hubo que encontrar la forma de que no duplicara la información de las reproducciones y
 lo resolvimos con un MAX(Playcount) para LastFM y con un MIN(Genre) para Spotify y agrupando por artista en ambos casos.
 En LastFM:Elige mayor Playcount por artista y agrupa por artista para evitar que un artista con múltiples registros se duplique en el JOIN.
 En Spotify si un artista tiene varios géneros tomamos el primero en orden alfabético y se agrupa por artista para evitar que un artista aparezca varias veces
 con distintos géneros.
 */
 
SELECT 
    s.Genre, 
    SUM(l.Playcount) AS Total_Playcount
FROM (
    -- Eliminamos duplicados en LastFM, asegurándonos que cada artista tenga solo un Playcount
    SELECT Artist, MAX(Playcount) AS Playcount
    FROM LastFM
    GROUP BY Artist
) l
INNER JOIN (
    -- Eliminamos duplicados en Spotify, asegurando que cada artista tenga sólo un género. El MIN elige un único genero por artista
    SELECT Artist, MIN(Genre) AS Genre
    FROM Spotify
    GROUP BY Artist
) s ON s.Artist = l.Artist
GROUP BY s.Genre
ORDER BY Total_Playcount DESC;


-- Los 9 artistas más escuchados:
# Esta consulta nos devolverá 10 resultados, pero esto es debido a que el artista "Drake" se duplica, inevitablemente, al
# estar categorizado en Spotify en dos categorías de género diferentes: Pop y Rap

SELECT 
    s.Artist, 
    s.Genre, 
    MAX(l.Playcount) AS Total_Playcount
FROM LastFM l
INNER JOIN Spotify s ON s.Artist = l.Artist
GROUP BY s.Artist, s.Genre
ORDER BY Total_Playcount DESC
LIMIT 10;


-- Géneros con más oyentes:

SELECT 
    s.Genre, 
    SUM(l.Listeners) AS Total_Listeners
FROM (
    -- Eliminamos duplicados en LastFM, asegurándonos que cada artista tenga solo un Listeners
    SELECT Artist, MAX(Listeners) AS Listeners
    FROM LastFM
    GROUP BY Artist
) l
INNER JOIN (
    -- Eliminamos duplicados en Spotify, asegurándonos que cada artista tenga sólo un género. El MIN elige un único género por artista.
    SELECT DISTINCT Artist, MIN(Genre) AS Genre
    FROM Spotify
    GROUP BY Artist
) s ON s.Artist = l.Artist
GROUP BY s.Genre
ORDER BY Total_Listeners DESC;


-- Los 9 artistas con más oyentes:
# Esta consulta nos devolverá 10 resultados, pero esto es debido a que el artista "Drake" se duplica, inevitablemente, al
# estar categorizado en Spotify en dos categorías de género diferentes: Pop y Rap

SELECT 
    s.Artist, 
    s.Genre, 
    MAX(l.Listeners) AS Listeners
FROM LastFM l
INNER JOIN Spotify s ON s.Artist = l.Artist
GROUP BY s.Artist, s.Genre
ORDER BY Listeners DESC
LIMIT 10;


-- ¿Cuál fue el género con más canciones lanzadas por año?

SELECT 
    s.Year, 
    s.Genre, 
    COUNT(DISTINCT s.Track, s.Artist) AS Total_tracks # eliminando posibles duplicados
FROM Spotify s
GROUP BY s.Year, s.Genre
HAVING COUNT(DISTINCT s.Track, s.Artist) = (
    SELECT MAX(Total_tracks)
    FROM (
        SELECT 
            s2.Year, 
            s2.Genre, 
            COUNT(DISTINCT s2.Track, s2.Artist) AS Total_tracks
        FROM Spotify s2
        GROUP BY s2.Year, s2.Genre
    ) AS Genres_count
    WHERE Genres_count.Year = s.Year # esto asegura que la comparación se haga año por año
)
ORDER BY s.Year ASC;


-- Evolución del lanzamiento de canciones por año:

SELECT
	Year,
	COUNT(Track) AS Total_tracks
FROM Spotify
GROUP BY Year
ORDER BY Year ASC;


-- Y si queremos que nos lo muestre por género y año:

SELECT 
    Year,
    Genre,
    COUNT(Track) AS Total_tracks
FROM Spotify 
GROUP BY Year, Genre
ORDER BY Year ASC, Total_tracks DESC;


-- ¿Qué artista sacó más canciones durante la pandemia?

SELECT 
	Artist,
    COUNT(Track) AS Total_tracks
FROM Spotify
WHERE Year = 2020
GROUP BY Artist
ORDER BY Total_tracks DESC
LIMIT 1;


# Con respecto a la consulta anterior, ¿cuáles fueron esas canciones?

SELECT
    Track,
    Artist
FROM Spotify
WHERE Year = 2020
AND Artist =  "Bad Bunny";


-- ¿Cuál fue el género con más álbumes lanzados por año?

SELECT 
    s.Year, 
    s.Genre, 
    COUNT(DISTINCT s.Album) AS Total_albums # nos quita los álbumes duplicados
FROM Spotify s
GROUP BY s.Year, s.Genre
HAVING COUNT(DISTINCT s.Album) = (
    SELECT MAX(Total_albums)
    FROM (
        SELECT 
            s2.Year, 
            s2.Genre, 
            COUNT(DISTINCT s2.Album) AS Total_albums
        FROM Spotify s2
        GROUP BY s2.Year, s2.Genre
    ) AS Genres_count
    WHERE Genres_count.Year = s.Year # esto asegura que la comparación se haga año por año
)
ORDER BY s.Year ASC;


-- Evolución del lanzamiento de álbumes por año:

SELECT
	Year,
	COUNT(DISTINCT Album) AS Total_albums
FROM Spotify
GROUP BY Year
ORDER BY Year ASC;


-- Y si queremos que nos lo muestre por género y año:

SELECT 
    Year,
    Genre,
    COUNT(DISTINCT Album) AS Total_albums
FROM Spotify
GROUP BY Year, Genre
ORDER BY Year ASC, Total_albums DESC;


-- ¿Qué artista sacó más álbumes durante la pandemia?

SELECT 
	Artist,
    COUNT(DISTINCT Album) AS Total_albums
FROM Spotify
WHERE Year = 2020
GROUP BY Artist
ORDER BY Total_albums DESC
LIMIT 1;


# Con respecto a la consulta anterior, ¿cuáles fueron esos álbumes?

SELECT
    DISTINCT(Album),
    Artist
FROM Spotify
WHERE Year = 2020
AND Artist =  "Myke Towers";


-- Evolución de colaboraciones por género:

SELECT Genre, COUNT(*) AS Total_Colaboraciones
FROM Spotify
WHERE Track IS NOT NULL 
AND (Track LIKE '%feat%'
     OR Track LIKE '%with%' 
     OR Track LIKE '%Ft.%')
GROUP BY Genre
ORDER BY Total_Colaboraciones DESC;


-- Evolución de colaboraciones por año:

SELECT 
	Year, 
    COUNT(*) AS Total_Colaboraciones
FROM Spotify
WHERE Track IS NOT NULL 
AND (Track LIKE '%feat%' 
     OR Track LIKE '%with%' 
     OR Track LIKE '%Ft.%')
GROUP BY Year
ORDER BY Year ASC;


-- Evolución de las colaboraciones por género y año:

SELECT 
	Year, 
    Genre, 
    COUNT(*) AS Num_colaboraciones
FROM Spotify
WHERE Track IS NOT NULL 
AND (Track LIKE '%feat%' 
     OR Track LIKE '%with%' 
     OR Track LIKE '%Ft.%')
GROUP BY year, Genre
ORDER BY year ASC, Num_colaboraciones DESC;


-- ¿Cuantos artistas han realizado colaboraciones?

SELECT 
    COUNT(DISTINCT Artist) AS total_artistas_con_colaboraciones
FROM Spotify
WHERE 
    (Track IS NOT NULL) AND 
    (Track LIKE '%feat%' OR Track LIKE '%with%' OR Track LIKE '%Ft.%');


-- Y si quiero saber cuantos artistas tienen mas de una colaboración y cuantas colaboraciones han hecho:

SELECT 
    COUNT(Artist) AS total_artistas_con_colaboraciones,
    SUM(total_colaboraciones) AS total_colaboraciones
FROM (
    SELECT 
        Artist,
        COUNT(*) AS total_colaboraciones
    FROM Spotify
    WHERE 
        (Track IS NOT NULL) AND 
        (Track LIKE '%feat%' OR Track LIKE '%with%' OR Track LIKE '%Ft.%')
    GROUP BY Artist
    HAVING COUNT(*) > 1
) AS artistas_con_colaboraciones;


-- Artistas con más de dos colaboraciones:

SELECT 
    Artist, 
    COUNT(*) AS total_colaboraciones
FROM Spotify
WHERE 
    (Track IS NOT NULL) AND 
    (Track LIKE '%feat%' OR Track LIKE '%with%' OR Track LIKE '%Ft.%')
GROUP BY Artist
HAVING COUNT(*) > 2
ORDER BY total_colaboraciones DESC;