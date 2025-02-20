-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 20 fév. 2025 à 23:28
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cargomaster_db`
--

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_states` ()   BEGIN
    UPDATE states SET record_count = (SELECT COUNT(*) FROM clients) WHERE table_name = 'clients';
    UPDATE states SET record_count = (SELECT COUNT(*) FROM colis) WHERE table_name = 'colis';
    UPDATE states SET record_count = (SELECT COUNT(*) FROM livraisons) WHERE table_name = 'livraisons';
    UPDATE states SET record_count = (SELECT COUNT(*) FROM expeditions) WHERE table_name = 'expeditions';
    UPDATE states SET record_count = (SELECT COUNT(*) FROM chauffeurs) WHERE table_name = 'chauffeurs';
    UPDATE states SET record_count = (SELECT COUNT(*) FROM vehicules) WHERE table_name = 'vehicules';
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `administrateur`
--

CREATE TABLE `administrateur` (
  `id_admin` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `passwords` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `administrateur`
--

INSERT INTO `administrateur` (`id_admin`, `email`, `passwords`) VALUES
(1, 'master@gmail.com', '$2y$10$DDNnknEpLNMB39uEwpIE9Ocjy3AlB.6yEUQUt6.Qkrs9ojenA7W/K');

-- --------------------------------------------------------

--
-- Structure de la table `chauffeurs`
--

CREATE TABLE `chauffeurs` (
  `chauffeur_id` int(11) NOT NULL,
  `noms` varchar(100) NOT NULL,
  `types` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `passwords` varchar(100) NOT NULL,
  `vehicule_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `chauffeurs`
--

INSERT INTO `chauffeurs` (`chauffeur_id`, `noms`, `types`, `email`, `telephone`, `passwords`, `vehicule_id`) VALUES
(1, 'archi luv', '', 'archi@gmail.com', '1234567', '', 2),
(3, 'joe john', 'capitaine', 'joe@gmail.com', '98765432', '$2y$10$lQqbvaGeIu2RWjH.gqt4w.5RZgXGD7o8YtDRujWYeD1eWFyDmbiEW', 2),
(5, 'arsene moise', 'Pilote', 'arsene@gmail.com', '098767890', '$2y$10$HxIodjWDgDjvyp26mlcKkuJhQR2pLcz2mHsJ08rGuQ/2HPDFOBkoS', 1),
(6, 'ARIO mario', 'chauffeur', 'mario@gmail.com', '0999582156', '$2y$10$aq1vC9H9aNekpoX4SaaQvuMTi/ER8T9uhZynceJev38l15SvH.f8a', 3);

--
-- Déclencheurs `chauffeurs`
--
DELIMITER $$
CREATE TRIGGER `after_delete_chauffeurs` AFTER DELETE ON `chauffeurs` FOR EACH ROW UPDATE states SET record_count = record_count - 1 WHERE table_name = 'chauffeurs'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_chauffeurs` AFTER INSERT ON `chauffeurs` FOR EACH ROW UPDATE states SET record_count = record_count + 1 WHERE table_name = 'chauffeurs'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `clients`
--

CREATE TABLE `clients` (
  `client_id` int(11) NOT NULL,
  `noms` varchar(100) NOT NULL,
  `adresse` text NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `date_ajout` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `clients`
--

INSERT INTO `clients` (`client_id`, `noms`, `adresse`, `telephone`, `email`, `date_ajout`) VALUES
(1, 'Happy Kasoki', 'Kigali,Gisozi', '09876543', 'happy@gmail.com', '2025-02-13 08:50:59'),
(2, 'Luvagho furaha', 'Goma,RDC', '09098765', 'furaha@gmail.com', '2025-02-13 09:11:12'),
(3, 'abiga kavira', 'kirumba,RDC', '678909876', 'abiga@gmail.com', '2025-02-13 09:11:46'),
(4, 'espe luvagho', 'kagugu', '12345678', 'espe@gmail.com', '2025-02-13 09:12:26'),
(5, 'Archimed kam', 'DCR,Kinshasa', '25678654', 'archimed@gmail.com', '2025-02-16 09:36:09');

--
-- Déclencheurs `clients`
--
DELIMITER $$
CREATE TRIGGER `after_delete_clients` AFTER DELETE ON `clients` FOR EACH ROW UPDATE states SET record_count = record_count - 1 WHERE table_name = 'clients'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_clients` AFTER INSERT ON `clients` FOR EACH ROW UPDATE states SET record_count = record_count + 1 WHERE table_name = 'clients'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `colis`
--

CREATE TABLE `colis` (
  `colis_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `noms_client` varchar(100) NOT NULL,
  `descriptions` varchar(100) NOT NULL,
  `poids` decimal(10,2) DEFAULT NULL,
  `adresse_livraison` text NOT NULL,
  `date_enregistrement` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `colis`
--

INSERT INTO `colis` (`colis_id`, `client_id`, `noms_client`, `descriptions`, `poids`, `adresse_livraison`, `date_enregistrement`) VALUES
(4, 1, 'Happy Kasoki', 'Deux voiture Mercedes blue', 1000.00, 'DRC,Butembo', '2025-02-13 10:28:24'),
(5, 2, 'Luvagho furaha', 'Cinq Royce Roll', 1500.00, 'Gisenyi,Rwanda', '2025-02-13 10:29:24'),
(8, 4, 'espe luvagho', 'huit cargo voiture', 1000.00, 'nairobi,kenya', '2025-02-15 21:08:48'),
(9, 5, 'Archimed kam', 'cinq sac montre rolex', 50.00, 'DRC,Kinshasa', '2025-02-16 09:36:48'),
(10, 1, 'Happy Kasoki', 'trente toyota rouge', 4000.00, 'Kampala,Uganda', '2025-02-17 11:40:41'),
(11, 5, 'Archimed kam', 'cinq sac gucci', 50.00, 'caire,Egypte', '2025-02-18 11:41:01');

--
-- Déclencheurs `colis`
--
DELIMITER $$
CREATE TRIGGER `after_delete_colis` AFTER DELETE ON `colis` FOR EACH ROW UPDATE states SET record_count = record_count - 1 WHERE table_name = 'colis'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_colis` AFTER INSERT ON `colis` FOR EACH ROW UPDATE states SET record_count = record_count + 1 WHERE table_name = 'colis'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `colis_livraison`
--

CREATE TABLE `colis_livraison` (
  `id` int(11) NOT NULL,
  `colis_id` int(11) NOT NULL,
  `livraison_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `expeditions`
--

CREATE TABLE `expeditions` (
  `expedition_id` int(11) NOT NULL,
  `livraison_id` int(11) NOT NULL,
  `chauffeur_id` int(11) NOT NULL,
  `position_actuelle` point DEFAULT NULL,
  `etat` enum('En route','Retardée','Livrée') DEFAULT 'En route'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `expeditions`
--

INSERT INTO `expeditions` (`expedition_id`, `livraison_id`, `chauffeur_id`, `position_actuelle`, `etat`) VALUES
(1, 9, 3, 0x000000000101000000f3cf679b76acfebfc87663e6a70d3e40, 'Livrée'),
(2, 7, 6, 0x00000000010100000000f4458ce8a8febf52f2ea1c030e3e40, 'Livrée'),
(3, 10, 6, 0x000000000101000000c87663e6a70d3e40f3cf679b76acfebf, 'Retardée');

--
-- Déclencheurs `expeditions`
--
DELIMITER $$
CREATE TRIGGER `after_delete_expeditions` AFTER DELETE ON `expeditions` FOR EACH ROW UPDATE states SET record_count = record_count - 1 WHERE table_name = 'expeditions'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_expeditions` AFTER INSERT ON `expeditions` FOR EACH ROW UPDATE states SET record_count = record_count + 1 WHERE table_name = 'expeditions'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `itineraires`
--

CREATE TABLE `itineraires` (
  `itineraire_id` int(11) NOT NULL,
  `livraison_id` int(11) NOT NULL,
  `point_depart` text NOT NULL,
  `point_arrivee` text NOT NULL,
  `distance_km` decimal(10,2) NOT NULL,
  `duree_estimee` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `livraisons`
--

CREATE TABLE `livraisons` (
  `livraison_id` int(11) NOT NULL,
  `vehicule_id` int(11) NOT NULL,
  `chauffeur_id` int(11) NOT NULL,
  `date_depart` datetime NOT NULL DEFAULT current_timestamp(),
  `date_arrivee_prevue` datetime NOT NULL DEFAULT current_timestamp(),
  `itineraire` point NOT NULL,
  `statut` enum('Planifiée','En cours','Terminée','Annulée') DEFAULT 'Planifiée',
  `colis_id` int(11) NOT NULL,
  `statut_colis` enum('Prêt à être livré','En cours de livraison','Livré') NOT NULL DEFAULT 'Prêt à être livré'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `livraisons`
--

INSERT INTO `livraisons` (`livraison_id`, `vehicule_id`, `chauffeur_id`, `date_depart`, `date_arrivee_prevue`, `itineraire`, `statut`, `colis_id`, `statut_colis`) VALUES
(6, 3, 6, '2025-02-18 13:28:00', '2025-02-19 13:28:00', 0x00000000010100000091779261674c3d40122061749ac4ca3f, 'Planifiée', 4, 'Prêt à être livré'),
(7, 3, 6, '2025-02-20 17:29:00', '2025-02-24 17:29:00', 0x0000000001010000008e85ae139c413d400625b01b3272fabf, 'Planifiée', 5, 'Prêt à être livré'),
(8, 1, 5, '2025-02-27 17:30:00', '2025-02-28 18:30:00', 0x000000000101000000c0b00fdce76c42409094df1310b9f3bf, 'Planifiée', 8, 'Prêt à être livré'),
(9, 2, 3, '2025-02-11 13:31:00', '2025-02-14 17:31:00', 0x00000000010100000016269ef327a82e403d5d92a5ef7c11c0, 'Planifiée', 9, 'Prêt à être livré'),
(10, 3, 6, '2025-02-20 23:06:00', '2025-02-20 23:06:00', 0x000000000101000000c2385d9b634b4040518d007a7d4cd63f, 'Planifiée', 10, 'Prêt à être livré');

--
-- Déclencheurs `livraisons`
--
DELIMITER $$
CREATE TRIGGER `after_delete_livraisons` AFTER DELETE ON `livraisons` FOR EACH ROW UPDATE states SET record_count = record_count - 1 WHERE table_name = 'livraisons'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_livraisons` AFTER INSERT ON `livraisons` FOR EACH ROW UPDATE states SET record_count = record_count + 1 WHERE table_name = 'livraisons'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `assign_vehicule` BEFORE INSERT ON `livraisons` FOR EACH ROW BEGIN
    DECLARE v_id INT;
    
    -- Vérifier si le chauffeur existe avant d'assigner le véhicule
    SELECT vehicule_id INTO v_id FROM chauffeurs WHERE chauffeur_id = NEW.chauffeur_id LIMIT 1;

    IF v_id IS NOT NULL THEN
        SET NEW.vehicule_id = v_id;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erreur: Chauffeur introuvable';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `states`
--

CREATE TABLE `states` (
  `id` int(11) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `record_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `states`
--

INSERT INTO `states` (`id`, `table_name`, `record_count`) VALUES
(1, 'clients', 5),
(2, 'colis', 6),
(3, 'livraisons', 5),
(4, 'expeditions', 3),
(5, 'chauffeurs', 4),
(6, 'vehicules', 4);

-- --------------------------------------------------------

--
-- Structure de la table `vehicules`
--

CREATE TABLE `vehicules` (
  `vehicule_id` int(11) NOT NULL,
  `marque` varchar(50) NOT NULL,
  `modele` varchar(50) NOT NULL,
  `immatriculation` varchar(20) NOT NULL,
  `statut` enum('Disponible','En livraison','En maintenance') DEFAULT 'Disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `vehicules`
--

INSERT INTO `vehicules` (`vehicule_id`, `marque`, `modele`, `immatriculation`, `statut`) VALUES
(1, 'Avion', 'boing 123', 'bb54', 'Disponible'),
(2, 'Bateau', 'chip10', 'ch89', 'Disponible'),
(3, 'Truck ', 'truck toyota', 'tr56', 'Disponible'),
(4, 'Speed Jet', 'Jet2020', 'jet678', 'Disponible');

--
-- Déclencheurs `vehicules`
--
DELIMITER $$
CREATE TRIGGER `after_delete_vehicules` AFTER DELETE ON `vehicules` FOR EACH ROW UPDATE states SET record_count = record_count - 1 WHERE table_name = 'vehicules'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_vehicules` AFTER INSERT ON `vehicules` FOR EACH ROW UPDATE states SET record_count = record_count + 1 WHERE table_name = 'vehicules'
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `administrateur`
--
ALTER TABLE `administrateur`
  ADD PRIMARY KEY (`id_admin`);

--
-- Index pour la table `chauffeurs`
--
ALTER TABLE `chauffeurs`
  ADD PRIMARY KEY (`chauffeur_id`),
  ADD UNIQUE KEY `permis` (`email`),
  ADD KEY `vehicule_id` (`vehicule_id`);

--
-- Index pour la table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`client_id`),
  ADD UNIQUE KEY `telephone` (`telephone`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `colis`
--
ALTER TABLE `colis`
  ADD PRIMARY KEY (`colis_id`),
  ADD KEY `client_id` (`client_id`);

--
-- Index pour la table `colis_livraison`
--
ALTER TABLE `colis_livraison`
  ADD PRIMARY KEY (`id`),
  ADD KEY `colis_id` (`colis_id`),
  ADD KEY `livraison_id` (`livraison_id`);

--
-- Index pour la table `expeditions`
--
ALTER TABLE `expeditions`
  ADD PRIMARY KEY (`expedition_id`),
  ADD KEY `livraison_id` (`livraison_id`);

--
-- Index pour la table `itineraires`
--
ALTER TABLE `itineraires`
  ADD PRIMARY KEY (`itineraire_id`),
  ADD KEY `livraison_id` (`livraison_id`);

--
-- Index pour la table `livraisons`
--
ALTER TABLE `livraisons`
  ADD PRIMARY KEY (`livraison_id`),
  ADD UNIQUE KEY `unique_colis` (`colis_id`),
  ADD KEY `vehicule_id` (`vehicule_id`),
  ADD KEY `chauffeur_id` (`chauffeur_id`);

--
-- Index pour la table `states`
--
ALTER TABLE `states`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `table_name` (`table_name`);

--
-- Index pour la table `vehicules`
--
ALTER TABLE `vehicules`
  ADD PRIMARY KEY (`vehicule_id`),
  ADD UNIQUE KEY `immatriculation` (`immatriculation`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `administrateur`
--
ALTER TABLE `administrateur`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `chauffeurs`
--
ALTER TABLE `chauffeurs`
  MODIFY `chauffeur_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `clients`
--
ALTER TABLE `clients`
  MODIFY `client_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `colis`
--
ALTER TABLE `colis`
  MODIFY `colis_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `colis_livraison`
--
ALTER TABLE `colis_livraison`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `expeditions`
--
ALTER TABLE `expeditions`
  MODIFY `expedition_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `itineraires`
--
ALTER TABLE `itineraires`
  MODIFY `itineraire_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `livraisons`
--
ALTER TABLE `livraisons`
  MODIFY `livraison_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `states`
--
ALTER TABLE `states`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `vehicules`
--
ALTER TABLE `vehicules`
  MODIFY `vehicule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `chauffeurs`
--
ALTER TABLE `chauffeurs`
  ADD CONSTRAINT `chauffeurs_ibfk_1` FOREIGN KEY (`vehicule_id`) REFERENCES `vehicules` (`vehicule_id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `colis`
--
ALTER TABLE `colis`
  ADD CONSTRAINT `colis_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`client_id`);

--
-- Contraintes pour la table `colis_livraison`
--
ALTER TABLE `colis_livraison`
  ADD CONSTRAINT `colis_livraison_ibfk_1` FOREIGN KEY (`colis_id`) REFERENCES `colis` (`colis_id`),
  ADD CONSTRAINT `colis_livraison_ibfk_2` FOREIGN KEY (`livraison_id`) REFERENCES `livraisons` (`livraison_id`);

--
-- Contraintes pour la table `expeditions`
--
ALTER TABLE `expeditions`
  ADD CONSTRAINT `expeditions_ibfk_1` FOREIGN KEY (`livraison_id`) REFERENCES `livraisons` (`livraison_id`);

--
-- Contraintes pour la table `itineraires`
--
ALTER TABLE `itineraires`
  ADD CONSTRAINT `itineraires_ibfk_1` FOREIGN KEY (`livraison_id`) REFERENCES `livraisons` (`livraison_id`);

--
-- Contraintes pour la table `livraisons`
--
ALTER TABLE `livraisons`
  ADD CONSTRAINT `livraisons_ibfk_1` FOREIGN KEY (`vehicule_id`) REFERENCES `vehicules` (`vehicule_id`),
  ADD CONSTRAINT `livraisons_ibfk_2` FOREIGN KEY (`chauffeur_id`) REFERENCES `chauffeurs` (`chauffeur_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
