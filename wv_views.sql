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

--------------------------------
-- ALL_PLAYERS_ELAPSED_GAME - Vue détaillée des joueurs avec leur temps de jeu par partie
CREATE OR ALTER VIEW ALL_PLAYERS_ELAPSED_GAME AS
SELECT 
    p.pseudo AS 'nom du joueur',
    pa.title_party AS 'nom de la partie',
    participants.nb_participants AS 'nombre de participants',
    MIN(t.start_time) AS 'date et heure de la première action du joueur dans la partie',
    MAX(pp.end_time) AS 'date et heure de la dernière action du joueur dans la partie',
    DATEDIFF(SECOND, MIN(t.start_time), MAX(pp.end_time)) AS 'nb de secondes passées dans la partie pour le joueur'
FROM 
    players p
    INNER JOIN players_in_parties pip ON p.id_player = pip.id_player
    INNER JOIN parties pa ON pip.id_party = pa.id_party
    LEFT JOIN players_play pp ON p.id_player = pp.id_player
    LEFT JOIN turns t ON pp.id_turn = t.id_turn AND t.id_party = pa.id_party
    CROSS APPLY (
        SELECT COUNT(*) AS nb_participants 
        FROM players_in_parties pip2 
        WHERE pip2.id_party = pa.id_party
    ) AS participants
WHERE
    t.start_time IS NOT NULL
GROUP BY 
    p.pseudo,
    pa.title_party,
    pa.id_party,
    participants.nb_participants;


--------------------------------
-- ALL_PLAYERS_ELAPSED_TOUR - Vue détaillée du temps de prise de décision par tour
CREATE OR ALTER VIEW ALL_PLAYERS_ELAPSED_TOUR AS
SELECT 
    p.pseudo AS 'nom du joueur',
    pa.title_party AS 'nom de la partie',
    t.id_turn AS 'n° du tour',  -- Changé de num_turn à id_turn
    t.start_time AS 'date et heure du début du tour',
    pp.end_time AS 'date et heure de la prise de décision du joueur dans le tour',
    DATEDIFF(SECOND, t.start_time, pp.end_time) AS 'nb de secondes passées dans le tour pour le joueur'
FROM 
    players p
    INNER JOIN players_play pp ON p.id_player = pp.id_player
    INNER JOIN turns t ON pp.id_turn = t.id_turn
    INNER JOIN parties pa ON t.id_party = pa.id_party
WHERE
    pp.end_time IS NOT NULL AND
    t.start_time IS NOT NULL;