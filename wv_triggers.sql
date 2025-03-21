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