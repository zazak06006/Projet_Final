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
