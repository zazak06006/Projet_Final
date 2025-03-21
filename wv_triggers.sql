--------------------------------
-- TRG_USERNAME_TO_LOWER - Trigger qui mets le username en lower lors de la creation.
CREATE OR ALTER TRIGGER TRG_USERNAME_TO_LOWER
ON players
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Mise à jour des nouveaux pseudos en minuscules
    UPDATE players
    SET pseudo = LOWER(pseudo)
    WHERE id_player IN (SELECT id_player FROM inserted);
END;
GO

--------------------------------
-- TRG_USERNAME_TO_LOWER - Trigger qui mets le username en lower lors de la creation.
CREATE OR ALTER TRIGGER TRG_COMPLETE_TOUR
ON turns
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TOUR_ID INT, @PARTY_ID INT;

    -- Loop through affected rows
    DECLARE tour_cursor CURSOR FOR
    SELECT id_turn, id_party FROM inserted
    WHERE end_time IS NOT NULL;  -- Ensure that the turn is completed

    OPEN tour_cursor;
    FETCH NEXT FROM tour_cursor INTO @TOUR_ID, @PARTY_ID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Call the procedure to complete the turn
        EXEC COMPLETE_TOUR @TOUR_ID, @PARTY_ID;

        FETCH NEXT FROM tour_cursor INTO @TOUR_ID, @PARTY_ID;
    END;

    CLOSE tour_cursor;
    DEALLOCATE tour_cursor;
END;
GO