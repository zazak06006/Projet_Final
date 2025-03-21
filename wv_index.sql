USE testsql;

-- Suppression des tables existantes pour les recréer proprement
IF OBJECT_ID('players_play', 'U') IS NOT NULL DROP TABLE players_play;
IF OBJECT_ID('turns', 'U') IS NOT NULL DROP TABLE turns;
IF OBJECT_ID('players_in_parties', 'U') IS NOT NULL DROP TABLE players_in_parties;
IF OBJECT_ID('players', 'U') IS NOT NULL DROP TABLE players;
IF OBJECT_ID('roles', 'U') IS NOT NULL DROP TABLE roles;
IF OBJECT_ID('parties', 'U') IS NOT NULL DROP TABLE parties;

-- Création des tables avec les bonnes contraintes
CREATE TABLE parties (
    id_party INT NOT NULL PRIMARY KEY,
    title_party VARCHAR(255) NOT NULL,
    winner_role VARCHAR(255) NULL  -- Ajout de la colonne pour stocker le rôle gagnant
);

CREATE TABLE roles (
    id_role INT NOT NULL PRIMARY KEY,
    description_role VARCHAR(255) NOT NULL
);

CREATE TABLE players (
    id_player INT NOT NULL PRIMARY KEY,
    pseudo VARCHAR(255) NOT NULL
);

CREATE TABLE players_in_parties (
    id_party INT NOT NULL,
    id_player INT NOT NULL,
    id_role INT NOT NULL,
    is_alive VARCHAR(5) NOT NULL,
    CONSTRAINT PK_players_in_parties PRIMARY KEY (id_party, id_player),
    CONSTRAINT FK_pip_parties FOREIGN KEY (id_party) REFERENCES parties(id_party),
    CONSTRAINT FK_pip_players FOREIGN KEY (id_player) REFERENCES players(id_player),
    CONSTRAINT FK_pip_roles FOREIGN KEY (id_role) REFERENCES roles(id_role)
);

CREATE TABLE turns (
    id_turn INT NOT NULL PRIMARY KEY,
    id_party INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS', -- Ajout d'une colonne status pour suivre l'état du tour
    CONSTRAINT FK_turns_parties FOREIGN KEY (id_party) REFERENCES parties(id_party),
    CONSTRAINT CK_turns_status CHECK (status IN ('IN_PROGRESS', 'COMPLETED', 'CANCELLED'))
);

CREATE TABLE players_play (
    id_player INT NOT NULL,
    id_turn INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    action VARCHAR(10) NOT NULL,
    origin_position_col VARCHAR(10) NULL,
    origin_position_row VARCHAR(10) NULL,
    target_position_col VARCHAR(10) NULL,
    target_position_row VARCHAR(10) NULL,
    CONSTRAINT PK_players_play PRIMARY KEY (id_player, id_turn),
    CONSTRAINT FK_pp_players FOREIGN KEY (id_player) REFERENCES players(id_player),
    CONSTRAINT FK_pp_turns FOREIGN KEY (id_turn) REFERENCES turns(id_turn)
);
