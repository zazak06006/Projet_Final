-- Résumé des modifications SQL entre les deux fichiers 
-- Pour exo-Views

-- 1. Ajout de la sélection de base de données et suppression des tables existantes
USE testsql;
GO

IF OBJECT_ID('players_play', 'U') IS NOT NULL DROP TABLE players_play;
IF OBJECT_ID('turns', 'U') IS NOT NULL DROP TABLE turns;
IF OBJECT_ID('players_in_parties', 'U') IS NOT NULL DROP TABLE players_in_parties;
IF OBJECT_ID('players', 'U') IS NOT NULL DROP TABLE players;
IF OBJECT_ID('roles', 'U') IS NOT NULL DROP TABLE roles;
IF OBJECT_ID('parties', 'U') IS NOT NULL DROP TABLE parties;

-- 2. Modifications pour la table parties
-- Avant: id_party int, title_party text
-- Après:
ALTER TABLE parties 
    ALTER COLUMN id_party INT NOT NULL;
ALTER TABLE parties 
    ALTER COLUMN title_party VARCHAR(255) NOT NULL;
ALTER TABLE parties 
    ADD CONSTRAINT PK_parties PRIMARY KEY (id_party);

-- 3. Modifications pour la table roles
-- Avant: id_role int, description_role text
-- Après:
ALTER TABLE roles 
    ALTER COLUMN id_role INT NOT NULL;
ALTER TABLE roles 
    ALTER COLUMN description_role VARCHAR(255) NOT NULL;
ALTER TABLE roles 
    ADD CONSTRAINT PK_roles PRIMARY KEY (id_role);

-- 4. Modifications pour la table players
-- Avant: id_player int, pseudo text
-- Après:
ALTER TABLE players 
    ALTER COLUMN id_player INT NOT NULL;
ALTER TABLE players 
    ALTER COLUMN pseudo VARCHAR(255) NOT NULL;
ALTER TABLE players 
    ADD CONSTRAINT PK_players PRIMARY KEY (id_player);

-- 5. Modifications pour la table players_in_parties
-- Avant: id_party int, id_player int, id_role int, is_alive text
-- Après:
ALTER TABLE players_in_parties 
    ALTER COLUMN id_party INT NOT NULL;
ALTER TABLE players_in_parties 
    ALTER COLUMN id_player INT NOT NULL;
ALTER TABLE players_in_parties 
    ALTER COLUMN id_role INT NOT NULL;
ALTER TABLE players_in_parties 
    ALTER COLUMN is_alive VARCHAR(5) NOT NULL;
ALTER TABLE players_in_parties 
    ADD CONSTRAINT PK_players_in_parties PRIMARY KEY (id_party, id_player);
ALTER TABLE players_in_parties 
    ADD CONSTRAINT FK_pip_parties FOREIGN KEY (id_party) REFERENCES parties(id_party);
ALTER TABLE players_in_parties 
    ADD CONSTRAINT FK_pip_players FOREIGN KEY (id_player) REFERENCES players(id_player);
ALTER TABLE players_in_parties 
    ADD CONSTRAINT FK_pip_roles FOREIGN KEY (id_role) REFERENCES roles(id_role);

-- 6. Modifications pour la table turns
-- Avant: id_turn int, id_party int, start_time datetime, end_time datetime
-- Après:
ALTER TABLE turns 
    ALTER COLUMN id_turn INT NOT NULL;
ALTER TABLE turns 
    ALTER COLUMN id_party INT NOT NULL;
ALTER TABLE turns 
    ALTER COLUMN start_time DATETIME NOT NULL;
ALTER TABLE turns 
    ALTER COLUMN end_time DATETIME NOT NULL;
ALTER TABLE turns 
    ADD CONSTRAINT PK_turns PRIMARY KEY (id_turn);
ALTER TABLE turns 
    ADD CONSTRAINT FK_turns_parties FOREIGN KEY (id_party) REFERENCES parties(id_party);

-- 7. Modifications pour la table players_play
-- Avant: id_player int, id_turn int, start_time datetime, end_time datetime, action varchar(10),
--        origin_position_col text, origin_position_row text, target_position_col text, target_position_row text
-- Après:
ALTER TABLE players_play 
    ALTER COLUMN id_player INT NOT NULL;
ALTER TABLE players_play 
    ALTER COLUMN id_turn INT NOT NULL;
ALTER TABLE players_play 
    ALTER COLUMN start_time DATETIME NOT NULL;
ALTER TABLE players_play 
    ALTER COLUMN end_time DATETIME NOT NULL;
ALTER TABLE players_play 
    ALTER COLUMN action VARCHAR(10) NOT NULL;
ALTER TABLE players_play 
    ALTER COLUMN origin_position_col VARCHAR(10) NULL;
ALTER TABLE players_play 
    ALTER COLUMN origin_position_row VARCHAR(10) NULL;
ALTER TABLE players_play 
    ALTER COLUMN target_position_col VARCHAR(10) NULL;
ALTER TABLE players_play 
    ALTER COLUMN target_position_row VARCHAR(10) NULL;
ALTER TABLE players_play 
    ADD CONSTRAINT PK_players_play PRIMARY KEY (id_player, id_turn);
ALTER TABLE players_play 
    ADD CONSTRAINT FK_pp_players FOREIGN KEY (id_player) REFERENCES players(id_player);
ALTER TABLE players_play 
    ADD CONSTRAINT FK_pp_turns FOREIGN KEY (id_turn) REFERENCES turns(id_turn);
