CREATE SEQUENCE produit_seq;

CREATE TABLE produit (
    ProduitId INT PRIMARY KEY DEFAULT(nextval('produit_seq')), 
    Nom_produit VARCHAR(60) NOT NULL
);

CREATE SEQUENCE entrepot_seq;

CREATE TABLE entrepot(
    EntrepotId INT PRIMARY KEY DEFAULT(nextval('entrepot_seq')),
    Adresse VARCHAR(80) NOT NULL,
    Superficie DOUBLE PRECISION NOT NULL,
    Hauteur DOUBLE PRECISION NOT NULL
);

CREATE TABLE entrepot_non_dispo(
    endId SERIAL PRIMARY KEY,
    EntrepotId INT,
    FOREIGN KEY(EntrepotId) REFERENCES entrepot(EntrepotId)
);

CREATE TABLE detail_entrepot(
    detail_entrepot_Id SERIAL PRIMARY KEY,
    EntrepotId INT,
    ProduitId INT,
    QuantiteStock DOUBLE PRECISION NOT NULL DEFAULT(0),
    FOREIGN KEY(ProduitId) REFERENCES produit(ProduitId),
    FOREIGN KEY(EntrepotId) REFERENCES entrepot(EntrepotId)
);

CREATE TABLE entre_stock(
    EntreId SERIAL PRIMARY KEY,
    EntrepotId INT,
    ProduitId INT,
    Date_entre DATE NOT NULL,
    Quantite DOUBLE PRECISION NOT NULL,
    FOREIGN KEY(ProduitId) REFERENCES produit(ProduitId),
    FOREIGN KEY(EntrepotId) REFERENCES entrepot(EntrepotId)
);

CREATE TABLE sortie_stock(
    SortieId SERIAL PRIMARY KEY,
    EntrepotId INT,
    ProduitId INT,
    Date_sortie DATE NOT NULL,
    Quantite DOUBLE PRECISION NOT NULL,
    Type_sortie SMALLINT,
    FOREIGN KEY(ProduitId) REFERENCES produit(ProduitId),
    FOREIGN KEY(EntrepotId) REFERENCES entrepot(EntrepotId)
);

-- INSERT INTO sortie_stock VALUES(1,1,3,'2023/06/02',2,1);

CREATE TABLE produit_non_dispo(
    pndId SERIAL PRIMARY KEY, 
    ProduitId INT,
    FOREIGN KEY(ProduitId) REFERENCES produit(ProduitId)
);

-- View commence par v_nomdelavue
CREATE VIEW v_historique_entre as 
    SELECT Date_entre,p.Nom_produit as Nom_produit,Quantite,e.Adresse as Adresse FROM entre_stock es JOIN produit p ON es.ProduitId = p.ProduitId JOIN entrepot e ON es.EntrepotId = e.EntrepotId;

CREATE OR REPLACE VIEW v_historique_sortie as 
    SELECT Date_sortie, CASE WHEN Type_sortie = 1 THEN 'Local' ELSE 'Exportation' END AS Type_sortie, p.Nom_produit as Nom_produit, Quantite, e.Adresse as Adresse  FROM sortie_stock ss JOIN produit p ON ss.ProduitId = p.ProduitId JOIN entrepot e ON ss.EntrepotId = e.EntrepotId;

CREATE VIEW v_p_dispo as 
    SELECT * FROM produit WHERE ProduitId NOT IN (SELECT ProduitId FROM produit_non_dispo);

CREATE VIEW v_e_dispo as 
    SELECT * FROM entrepot WHERE EntrepotId NOT IN (SELECT EntrepotId FROM entrepot_non_dispo);

CREATE VIEW v_liste_detail as 
    SELECT * FROM entrepot CROSS JOIN produit;

CREATE VIEW v_detail as 
    SELECT v.entrepotid,v.produitid,adresse,quantitestock FROM v_liste_detail v JOIN detail_entrepot d ON (v.entrepotid = d.entrepotid AND v.produitid = d.produitid);