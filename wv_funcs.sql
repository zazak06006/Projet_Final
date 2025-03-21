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