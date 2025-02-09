# Proyecto Music Stream

## Fase 3: Muestras de consultas en MySQLWorkbench

USE MusicStream;

SELECT * FROM Spotify;
SELECT * FROM LastFM; 

-- Géneros musicales más popularessegún el número de reproducciones  

SELECT 
    s.Genre, 
    SUM(l.Playcount) AS Total_Playcount
FROM (
    SELECT Artist, MAX(Playcount) AS Playcount
    FROM LastFM
    GROUP BY Artist
) l
INNER JOIN (
    SELECT Artist, MIN(Genre) AS Genre
    FROM Spotify
    GROUP BY Artist
) s ON s.Artist = l.Artist
GROUP BY s.Genre
ORDER BY Total_Playcount DESC;

-- Los 10 artistas más escuchados

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
    SELECT Artist, MAX(Listeners) AS Listeners
    FROM LastFM
    GROUP BY Artist
) l
INNER JOIN (
    SELECT DISTINCT Artist, MIN(Genre) AS Genre
    FROM Spotify
    GROUP BY Artist
) s ON s.Artist = l.Artist
GROUP BY s.Genre
ORDER BY Total_Listeners DESC;

-- Los 10 artistas con más oyentes

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
    COUNT(DISTINCT s.Track, s.Artist) AS Total_tracks 
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
    WHERE Genres_count.Year = s.Year 
)
ORDER BY s.Year ASC;


-- Evolución del lanzamiento de canciones por año.

SELECT
	Year,
	COUNT(Track) AS Total_tracks
FROM Spotify
GROUP BY Year
ORDER BY Year ASC;

-- Y si queremos que nos lo muestre por género y año.

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
    COUNT(DISTINCT s.Album) AS Total_albums 
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
    WHERE Genres_count.Year = s.Year 
)
ORDER BY s.Year ASC;

-- Evolución del lanzamiento de álbumes por año.

SELECT
	Year,
	COUNT(DISTINCT Album) AS Total_albums
FROM Spotify
GROUP BY Year
ORDER BY Year ASC;

-- Y si queremos que nos lo muestre por género y año.

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

-- artistas con mas de dos colaboraciones:

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


