-- ============================================================
-- IT-Manager : creation de la base de donnees (MySQL / MariaDB)
-- Noms alignes sur le MCD (identifiant de MATERIEL = num_serie)
-- ============================================================

CREATE DATABASE IF NOT EXISTS it_manager
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE it_manager;

-- ------------------------------------------------------------
-- 1. Tables sans cle etrangere
-- ------------------------------------------------------------

CREATE TABLE sites_geographiques (
    code_site INT          NOT NULL AUTO_INCREMENT,
    nom_site  VARCHAR(100) NOT NULL,
    ville     VARCHAR(100) NOT NULL,
    adresse   VARCHAR(255) NOT NULL,
    PRIMARY KEY (code_site)
) ENGINE=InnoDB;

CREATE TABLE services (
    code_service  INT           NOT NULL AUTO_INCREMENT,
    nom_service   VARCHAR(100)  NOT NULL,
    budget_annuel DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (code_service)
) ENGINE=InnoDB;

CREATE TABLE categorie (
    id_categorie            INT         NOT NULL AUTO_INCREMENT,
    libelle                 VARCHAR(50) NOT NULL,
    duree_amortissement_ans INT         NOT NULL DEFAULT 3,
    PRIMARY KEY (id_categorie)
) ENGINE=InnoDB;

CREATE TABLE fournisseur (
    id_fournisseur        INT          NOT NULL AUTO_INCREMENT,
    raison_sociale        VARCHAR(100) NOT NULL,
    contact_email         VARCHAR(150),
    telephone             VARCHAR(20),
    delai_livraison_jours INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (id_fournisseur)
) ENGINE=InnoDB;

CREATE TABLE logiciel (
    id_logiciel  INT          NOT NULL AUTO_INCREMENT,
    nom_logiciel VARCHAR(100) NOT NULL,
    editeur      VARCHAR(100) NOT NULL,
    version      VARCHAR(30),
    type_licence VARCHAR(50)  NOT NULL DEFAULT 'Commerciale',
    PRIMARY KEY (id_logiciel)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Tables avec cles etrangeres
-- ------------------------------------------------------------

CREATE TABLE collaborateur (
    matricule     VARCHAR(10)  NOT NULL,
    nom           VARCHAR(50)  NOT NULL,
    prenom        VARCHAR(50)  NOT NULL,
    email_pro     VARCHAR(150) NOT NULL,
    num_tel       VARCHAR(10),
    date_embauche DATE         NOT NULL,
    code_service  INT          NOT NULL,
    code_site     INT          NOT NULL,
    PRIMARY KEY (matricule),
    UNIQUE (email_pro),
    FOREIGN KEY (code_service) REFERENCES services (code_service)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (code_site) REFERENCES sites_geographiques (code_site)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE materiel (
    num_serie         VARCHAR(50)   NOT NULL,
    marque            VARCHAR(50)   NOT NULL,
    modele            VARCHAR(100)  NOT NULL,
    date_achat        DATE          NOT NULL,
    prix_achat_ht     DECIMAL(10,2) NOT NULL,
    date_fin_garantie DATE,
    etat              ENUM('En service', 'En stock', 'En panne', 'Reformé')
                      NOT NULL DEFAULT 'En stock',
    id_categorie      INT           NOT NULL,
    id_fournisseur    INT           NOT NULL,
    PRIMARY KEY (num_serie),
    FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_fournisseur) REFERENCES fournisseur (id_fournisseur)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. Tables issues des associations porteuses de donnees
-- ------------------------------------------------------------

CREATE TABLE attribuer (
    num_serie        VARCHAR(50) NOT NULL,
    matricule        VARCHAR(10) NOT NULL,
    date_attribution DATE        NOT NULL,
    date_restitution DATE        NULL DEFAULT NULL,
    commentaire_etat VARCHAR(255),
    PRIMARY KEY (num_serie, matricule, date_attribution),
    FOREIGN KEY (num_serie) REFERENCES materiel (num_serie)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (matricule) REFERENCES collaborateur (matricule)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (date_restitution IS NULL OR date_restitution >= date_attribution)
) ENGINE=InnoDB;

CREATE TABLE installer (
    num_serie         VARCHAR(50) NOT NULL,
    id_logiciel       INT         NOT NULL,
    date_installation DATE        NOT NULL,
    cle_licence       VARCHAR(100),
    PRIMARY KEY (num_serie, id_logiciel),
    FOREIGN KEY (num_serie) REFERENCES materiel (num_serie)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_logiciel) REFERENCES logiciel (id_logiciel)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Tickets d'incident
-- ------------------------------------------------------------

CREATE TABLE ticket (
    num_ticket        INT         NOT NULL AUTO_INCREMENT,
    date_ouverture    DATE        NOT NULL,
    description_panne TEXT        NOT NULL,
    niveau_urgence    ENUM('Faible', 'Moyen', 'Élevé', 'Critique')
                      NOT NULL DEFAULT 'Moyen',
    statut            ENUM('Ouvert', 'En cours', 'Résolu')
                      NOT NULL DEFAULT 'Ouvert',
    date_cloture      DATE        NULL DEFAULT NULL,
    num_serie         VARCHAR(50) NOT NULL,
    matricule         VARCHAR(10) NOT NULL,
    PRIMARY KEY (num_ticket),
    FOREIGN KEY (num_serie) REFERENCES materiel (num_serie)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (matricule) REFERENCES collaborateur (matricule)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (date_cloture IS NULL OR date_cloture >= date_ouverture)
) ENGINE=InnoDB;
