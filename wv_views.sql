--------------------------------
-- ALL_PLAYERS - Vue des joueurs avec leurs statistiques de participation
--Création de la vue
CREATE OR ALTER VIEW ALL_PLAYERS AS
SELECT 
    p.pseudo AS 'nom du joueur',
    COUNT(DISTINCT pip.id_party) AS 'nombre de parties jouées',
    COUNT(DISTINCT pp.id_turn) AS 'nombre de tours joués',
    MIN(t.start_time) AS 'date et heure de la première participation',
    MAX(pp.end_time) AS 'date et heure de la dernière action'
FROM 
    players p
    INNER JOIN players_in_parties pip ON p.id_player = pip.id_player
    LEFT JOIN players_play pp ON p.id_player = pp.id_player
    LEFT JOIN turns t ON pp.id_turn = t.id_turn
GROUP BY 
    p.pseudo
HAVING 
    COUNT(DISTINCT pip.id_party) > 0;

--Affichage de la vue
select * from ALL_PLAYERS;

--------------------------------
-- ALL_PLAYERS_ELAPSED_GAME - Vue des joueurs avec leurs statistiques de temps de jeu