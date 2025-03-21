--------------------------------
-- get_the_winner - fonctions qui renvoie les informations d'une partie
--Création de la fonction
CREATE OR ALTER FUNCTION get_the_winner(@partyid INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.pseudo AS winner_name,
        r.description_role AS winner_role,
        pa.title_party,
        COUNT(DISTINCT pp.id_turn) AS nb_turns_played,
        (SELECT COUNT(*) FROM turns WHERE id_party = @partyid) AS total_turns,
        AVG(DATEDIFF(SECOND, pp.start_time, pp.end_time)) AS avg_decision_time
    FROM players_in_parties pip
    JOIN players p ON pip.id_player = p.id_player
    JOIN roles r ON pip.id_role = r.id_role
    JOIN parties pa ON pip.id_party = pa.id_party
    LEFT JOIN players_play pp ON pip.id_player = pp.id_player
    WHERE pip.id_party = @partyid
    AND pip.is_alive = 'TRUE'  -- Seuls les survivants peuvent être vainqueurs
    GROUP BY p.pseudo, r.description_role, pa.title_party
);


--------------------------------
-- random_role - qui renvoie le prochain rôle à affecter au joueur en cours d’inscription
--Création de la fonction
CREATE OR ALTER FUNCTION random_role(@partyid INT)
RETURNS INT
AS
BEGIN
    DECLARE @total_players INT;
    DECLARE @current_wolves INT;
    DECLARE @current_villagers INT;
    DECLARE @wolf_quota INT;
    DECLARE @villager_quota INT;
    DECLARE @next_role INT;

    -- Définition des quotas (ex: 25% de loups, 75% de villageois)
    SELECT @total_players = COUNT(*) FROM players_in_parties WHERE id_party = @partyid;
    SET @wolf_quota = CEILING(@total_players * 0.25); -- 25% de loups
    SET @villager_quota = @total_players - @wolf_quota; -- 75% de villageois

    -- Compter les rôles déjà attribués
    SELECT 
        @current_wolves = COUNT(CASE WHEN r.description_role = 'Loup' THEN 1 END),
        @current_villagers = COUNT(CASE WHEN r.description_role = 'Villageois' THEN 1 END)
    FROM players_in_parties pip
    JOIN roles r ON pip.id_role = r.id_role
    WHERE pip.id_party = @partyid;

    -- Déterminer le rôle à assigner en respectant les quotas
    IF @current_wolves < @wolf_quota
        SET @next_role = (SELECT id_role FROM roles WHERE description_role = 'Loup');
    ELSE
        SET @next_role = (SELECT id_role FROM roles WHERE description_role = 'Villageois');

    RETURN @next_role;
END;

--------------------------------
-- random_position - qui renvoie une position aléatoire non encore utilisée dans une partie
--Création de la fonction
CREATE FUNCTION random_position(
    @id_party INT
)
RETURNS @result TABLE (
    col CHAR(1),
    row INT
)
AS
BEGIN
    -- Dimensions fixes du plateau (8x8 par défaut)
    DECLARE @num_rows INT = 8;
    DECLARE @num_cols INT = 8;
    
    -- Table temporaire pour stocker toutes les positions possibles avec une valeur aléatoire
    DECLARE @AllPositions TABLE (
        col CHAR(1),
        row INT,
        random_val INT
    );
    
    -- Table temporaire pour stocker les positions déjà utilisées
    DECLARE @UsedPositions TABLE (
        col CHAR(1),
        row INT
    );
    
    -- Générer toutes les positions possibles avec une valeur pseudo-aléatoire
    DECLARE @i INT = 0;
    WHILE @i < @num_cols
    BEGIN
        DECLARE @j INT = 1;
        WHILE @j <= @num_rows
        BEGIN
            INSERT INTO @AllPositions (col, row, random_val)
            VALUES (
                CHAR(65 + @i),  -- Convertit 0->A, 1->B, etc.
                @j,
                ABS(CHECKSUM(CONCAT(CAST(@id_party AS VARCHAR), CHAR(65 + @i), CAST(@j AS VARCHAR), CAST(GETDATE() AS VARCHAR))))
            );
            SET @j = @j + 1;
        END
        SET @i = @i + 1;
    END
    
    -- Récupérer les positions déjà utilisées dans cette partie
    -- Adaptez cette partie selon votre schéma de base de données
    INSERT INTO @UsedPositions (col, row)
    SELECT DISTINCT 
        origin_position_col, 
        origin_position_row
    FROM 
        players_play pp
        JOIN turns t ON pp.id_turn = t.id_turn
    WHERE 
        t.id_party = @id_party
        AND origin_position_col IS NOT NULL;
    
    -- Sélectionner une position aléatoire parmi celles non utilisées
    INSERT INTO @result (col, row)
    SELECT TOP 1
        ap.col,
        ap.row
    FROM 
        @AllPositions ap
    WHERE 
        NOT EXISTS (
            SELECT 1 
            FROM @UsedPositions up 
            WHERE up.col = ap.col AND up.row = ap.row
        )
    ORDER BY 
        ap.random_val;
    
    RETURN;
END;
GO


--SELECT * FROM random_position(1);
--GO