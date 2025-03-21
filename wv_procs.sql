--------------------------------
-- SEED_DATA - prcédure crée autant de tours de jeu que la partie peut en accepter
CREATE OR ALTER PROCEDURE SEED_DATA
    @NB_PLAYERS INT,
    @PARTY_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MAX_TURNS INT, @TURN_ID INT, @START_TIME DATETIME, @END_TIME DATETIME;

    -- Trouver le dernier id_turn existant pour éviter les doublons
    SELECT @TURN_ID = ISNULL(MAX(id_turn), 0) FROM turns;

    -- Déterminer le nombre maximal de tours à insérer
    SET @MAX_TURNS = @NB_PLAYERS;

    DECLARE @i INT = 1;
    WHILE @i <= @MAX_TURNS
    BEGIN
        SET @TURN_ID = @TURN_ID + 1; -- Générer un ID unique

        SET @START_TIME = DATEADD(MINUTE, (@i - 1) * 10, GETDATE());
        SET @END_TIME = DATEADD(MINUTE, 9, @START_TIME);

        -- Insérer le tour avec un ID unique
        INSERT INTO turns (id_turn, id_party, start_time, end_time)
        VALUES (@TURN_ID, @PARTY_ID, @START_TIME, @END_TIME);

        SET @i = @i + 1;
    END;
END;
GO

--------------------------------
-- COMPLETE_TOUR - prcédure qui applique toutes les demandes de déplacement.
CREATE OR ALTER PROCEDURE COMPLETE_TOUR
    @TOUR_ID INT,
    @PARTY_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PLAYER_ID INT, @TARGET_COL VARCHAR(10), @TARGET_ROW VARCHAR(10);

    -- Utilisation d'un curseur pour traiter les déplacements un par un
    DECLARE player_cursor CURSOR FOR
    SELECT id_player, target_position_col, target_position_row
    FROM players_play
    WHERE id_turn = @TOUR_ID
    ORDER BY start_time; -- Prioriser ceux qui ont soumis en premier

    OPEN player_cursor;
    FETCH NEXT FROM player_cursor INTO @PLAYER_ID, @TARGET_COL, @TARGET_ROW;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Vérifier si la position est déjà occupée par un autre joueur dans ce tour
        IF NOT EXISTS (
            SELECT 1 FROM players_play
            WHERE id_turn = @TOUR_ID
            AND target_position_col = @TARGET_COL
            AND target_position_row = @TARGET_ROW
            AND id_player <> @PLAYER_ID
        )
        BEGIN
            -- Appliquer le déplacement (mettre à jour les positions)
            UPDATE players_play
            SET origin_position_col = target_position_col,
                origin_position_row = target_position_row
            WHERE id_turn = @TOUR_ID
            AND id_player = @PLAYER_ID;
        END

        FETCH NEXT FROM player_cursor INTO @PLAYER_ID, @TARGET_COL, @TARGET_ROW;
    END;

    CLOSE player_cursor;
    DEALLOCATE player_cursor;

    PRINT 'Les déplacements du tour ont été appliqués.';
END;
GO

--------------------------------
-- USERNAME_TO_LOWER - prcédure qui mets tous les usernames on miniscule.
CREATE OR ALTER PROCEDURE USERNAME_TO_LOWER
AS
BEGIN
    SET NOCOUNT ON;

    -- Mise à jour des pseudos en minuscules
    UPDATE players
    SET pseudo = LOWER(pseudo);

    PRINT 'Tous les pseudos ont été convertis en minuscules.';
END;
GO