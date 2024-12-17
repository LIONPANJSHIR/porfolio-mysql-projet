-- Convertir la colonne 'SaleDate' en format date
-- Convert 'SaleDate' column into date format
SELECT saledate, str_to_date(saledate, '%M %d , %Y')
FROM data;

-- Mettre à jour la colonne 'SaleDate' avec la conversion
-- Update 'SaleDate' column with the conversion
UPDATE data 
SET saledate = str_to_date(saledate, '%M %d , %Y');

-- Visualiser les adresses des propriétés et trier
-- View and sort property addresses
SELECT propertyaddress FROM data ORDER BY 1;

-- Vérifier s'il y a des lignes vides
-- Check for empty rows
SELECT DISTINCT propertyaddress FROM data;

-- Observer des données dupliquées
-- Observe duplicate data
UPDATE data
SET propertyaddress = TRIM(propertyaddress);
SELECT DISTINCT propertyaddress FROM data;

-- Afficher les lignes où l'adresse est nulle
-- Display rows where the address is null
SELECT * FROM data WHERE PropertyAddress IS NULL;

-- Mettre à jour les adresses vides avec 'NULL'
-- Update empty addresses to 'NULL'
UPDATE data 
SET PropertyAddress = NULL WHERE propertyaddress = "";

-- Remplir les adresses manquantes en se basant sur les données disponibles
-- Fill missing addresses based on available data
SELECT 
    t1.PropertyAddress, t2.PropertyAddress,
    t1.SalePrice, t2.SalePrice,
    t1.TotalValue, t2.TotalValue,
    t1.SaleDate, t2.SaleDate
FROM data AS t1
JOIN data AS t2 
    ON t1.ParcelID = t2.ParcelID
    AND t1.UniqueID <> t2.UniqueID
WHERE t1.PropertyAddress IS NULL
    AND t2.PropertyAddress IS NOT NULL
    AND t1.acreage = t2.acreage;

-- Mettre à jour les adresses manquantes avec les données correspondantes
-- Update missing addresses with corresponding data
UPDATE data AS t1
JOIN data AS t2 
    ON t1.ParcelID = t2.ParcelID
    AND t1.UniqueID <> t2.UniqueID 
SET t1.propertyaddress = t2.propertyaddress 
WHERE t1.PropertyAddress IS NULL
    AND t2.PropertyAddress IS NOT NULL
    AND t1.acreage = t2.acreage;

-- Trouver la position de la virgule dans l'adresse
-- Find the position of the comma in the address
SELECT propertyaddress, LOCATE(",", propertyaddress) FROM data;

-- Séparer 'PropertyAddress' en 'Address' et 'City'
-- Split 'PropertyAddress' into 'Address' and 'City'
SELECT 
    PropertyAddress,
    SUBSTRING(propertyaddress, 1, LOCATE(",", propertyaddress) - 1) AS Address,
    SUBSTRING(propertyaddress, LOCATE(",", propertyaddress) + 1) AS City
FROM data;

-- Ajouter une colonne 'City' dans la table
-- Add a 'City' column to the table
ALTER TABLE data ADD City VARCHAR(250);

-- Mettre à jour la colonne 'City' avec les valeurs extraites
-- Update the 'City' column with extracted values
UPDATE data 
SET City = SUBSTRING(propertyaddress, LOCATE(",", propertyaddress) + 1);

-- Vérifier la modification de 'City'
-- Check the modification of 'City'
SELECT city FROM data;

-- Ajouter une colonne 'Address' dans la table
-- Add an 'Address' column to the table
ALTER TABLE data ADD Address VARCHAR(250);

-- Mettre à jour la colonne 'Address' avec les valeurs extraites
-- Update the 'Address' column with extracted values
UPDATE data 
SET Address = SUBSTRING(propertyaddress, 1, LOCATE(",", propertyaddress) - 1);

-- Vérifier la modification de 'Address'
-- Check the modification of 'Address'
SELECT Address FROM data;

-- Séparer l'adresse du propriétaire en différentes parties
-- Split the owner's address into different parts
SELECT owneraddress,
    SUBSTRING(owneraddress, 1, LOCATE(",", owneraddress) - 1),
    SUBSTRING(owneraddress, LOCATE(",", owneraddress) + 1, LOCATE(",", owneraddress)) 
FROM data;

-- Séparer l'adresse du propriétaire en adresse, ville et département
-- Split the owner's address into address, city, and state
SELECT OwnerAddress, 
    SUBSTRING(owneraddress, 1, LOCATE(",", owneraddress) - 1) AS address,
    SUBSTRING(owneraddress, LOCATE(",", owneraddress) + 1, LOCATE(",", owneraddress, LOCATE(",", owneraddress)) - 4) AS city,
    SUBSTRING(owneraddress, LOCATE(",", owneraddress, LOCATE(",", owneraddress) + 1) + 2, LOCATE(",", owneraddress, LOCATE(",", owneraddress))) AS departement
FROM data;

-- Ajouter trois nouvelles colonnes pour stocker les composants séparés de 'OwnerAddress'
-- Add three new columns to store the split components of 'OwnerAddress'
ALTER TABLE data
ADD COLUMN OwnerSplitAddress VARCHAR(250),
ADD COLUMN OwnerSplitCity VARCHAR(250),
ADD COLUMN OwnerSplitState VARCHAR(250);

-- Mettre à jour les colonnes avec les valeurs extraites de 'OwnerAddress'
-- Update the columns with extracted values from 'OwnerAddress'
UPDATE data
SET
    OwnerSplitAddress = SUBSTRING(owneraddress, 1, LOCATE(",", owneraddress) - 1),
    OwnerSplitCity = SUBSTRING(owneraddress, LOCATE(",", owneraddress) + 1, LOCATE(",", owneraddress, LOCATE(",", owneraddress)) - 4),
    OwnerSplitState = SUBSTRING(owneraddress, LOCATE(",", owneraddress, LOCATE(",", owneraddress) + 1) + 2, LOCATE(",", owneraddress, LOCATE(",", owneraddress)));

-- Vérifier les valeurs de 'SoldAsVacant'
-- Check the values of 'SoldAsVacant'
SELECT DISTINCT soldasvacant, COUNT(soldasvacant) FROM data GROUP BY SoldAsVacant;

-- Remplacer les valeurs 'Y' par 'YES' et 'N' par 'NON' dans 'SoldAsVacant'
-- Replace 'Y' with 'YES' and 'N' with 'NON' in 'SoldAsVacant'
UPDATE data
SET soldasvacant = "YES"
WHERE soldasvacant LIKE "Y%";

UPDATE data
SET soldasvacant = "NON"
WHERE soldasvacant LIKE "N%";

-- Identifier les doublons dans la table
-- Identify duplicates in the table
SELECT * , row_number() OVER (
    PARTITION BY landuse, ParcelID, uniqueid, saledate, FullBath, HalfBath, YearBuilt, TaxDistrict, saleprice, legalreference, owneraddress, OwnerName, totalvalue, Bedrooms, OwnerAddress, OwnerName
) FROM data;

-- Vérifier les doublons spécifiques
-- Check specific duplicates
WITH duplicate_cte AS (
    SELECT * ,
    row_number() OVER (
        PARTITION BY PropertyAddress, landuse, ParcelID, uniqueid, saledate, FullBath, HalfBath, YearBuilt, TaxDistrict, saleprice, legalreference, owneraddress, OwnerName, totalvalue, Bedrooms, OwnerAddress, OwnerName
    ) AS row_num 
    FROM data 
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

-- Mettre à jour 'LandUse' avec des valeurs normalisées
-- Update 'LandUse' with standardized values
SELECT DISTINCT LandUse FROM data ORDER BY 1;

SELECT DISTINCT
    LandUse,
    CASE
        WHEN LandUse LIKE "%CONDO%" THEN "CONDOMINIUM"
        WHEN LandUse LIKE "VACANT RE%" THEN "VACANT RESIDENTIAL LAND"
        WHEN landuse LIKE "GREENBEL%" THEN "GREENBELT RESIDENTIAL"
        ELSE LandUse
    END AS landuseUpdated
FROM data;

-- Ajouter une colonne 'LandUseUpdate' pour stocker les valeurs mises à jour
-- Add a 'LandUseUpdate' column to store updated values
ALTER TABLE data ADD LandUseUpdate VARCHAR(255);

-- Mettre à jour les valeurs de 'LandUseUpdate'
-- Update the 'LandUseUpdate' values
UPDATE data SET 
    LandUseUpdate = CASE
        WHEN LandUse LIKE "%CONDO%" THEN "CONDOMINIUM"
        WHEN LandUse LIKE "VACANT RE%" THEN "VACANT RESIDENTIAL LAND"
        WHEN landuse LIKE "GREENBEL%" THEN "GREENBELT RESIDENTIAL"
        ELSE LandUse
    END;

-- Vérifier les modifications sur 'LandUse' et 'LandUseUpdate'
-- Check the modifications on 'LandUse' and 'LandUseUpdate'
SELECT DISTINCT landuse, landuseupdate FROM data ORDER BY 1;

-- Créer une table 'data1' comme copie de la table 'data'
-- Create a 'data1' table as a copy of the 'data' table
CREATE TABLE data1 AS 
SELECT * FROM data;

-- Vérifier les données dans 'data1'
-- Check the data in 'data1'
SELECT * FROM data1;

-- Supprimer des colonnes dans 'data1'
-- Drop columns in 'data1'
ALTER TABLE data1 
DROP COLUMN landuse, 
DROP COLUMN owneraddress;

-- Identifier et supprimer les doublons dans 'data1'
-- Identify and remove duplicates in 'data1'
WITH duplicatecte AS (
    SELECT *,
    row_number() OVER (
        PARTITION BY parcelid, landuses, legalreference, saledate, saleprice, acreage, parcelid, yearbuilt, SoldAsVacant, BuildingValue, propertyaddress
    ) AS row_nums
    FROM data1
)
SELECT * 
FROM duplicatecte
WHERE row_nums > 1
ORDER BY PropertyAddress;

-- Créer une nouvelle table 'data2' sans certaines colonnes
-- Create a new 'data2' table without certain columns
CREATE TABLE data2 (
    UniqueID INT DEFAULT NULL,
    ParcelID TEXT,
    PropertyAddress TEXT,
    SaleDate TEXT,
    SalePrice INT DEFAULT NULL,
    LegalReference TEXT,
    SoldAsVacant TEXT,
    OwnerName TEXT,
    Acreage DOUBLE DEFAULT NULL,
    TaxDistrict TEXT,
    LandValue INT DEFAULT NULL,
    BuildingValue INT DEFAULT NULL,
    TotalValue INT DEFAULT NULL,
    YearBuilt INT DEFAULT NULL,
    Bedrooms INT DEFAULT NULL,
    FullBath INT DEFAULT NULL,
    HalfBath INT DEFAULT NULL,
    City VARCHAR(250) DEFAULT NULL,
    Address VARCHAR(250) DEFAULT NULL,
    OwnerSplitAddress VARCHAR(250) DEFAULT NULL,
    OwnerSplitCity VARCHAR(250) DEFAULT NULL,
    OwnerSplitState VARCHAR(250) DEFAULT NULL,
    Landuses VARCHAR(255) DEFAULT NULL,
    row_nums INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insérer les doublons dans 'data2' avec une logique de suppression des doublons
-- Insert duplicates into 'data2' with a logic to remove duplicates
INSERT INTO data2 
WITH duplicatecte AS (
    SELECT *,
    row_number() OVER (
        PARTITION BY parcelid, landuses, legalreference, saledate, saleprice, acreage, parcelid, yearbuilt, SoldAsVacant, BuildingValue, propertyaddress
    ) AS row_nums
    FROM data1
)
SELECT *
FROM duplicatecte
WHERE row_nums > 1
ORDER BY PropertyAddress;

-- Supprimer les lignes où les doublons existent dans 'data2'
-- Delete rows where duplicates exist in 'data2'
DELETE FROM data2 WHERE row_nums > 1;

-- Supprimer certaines colonnes de 'data2'
-- Drop specific columns from 'data2'
ALTER TABLE data2 
DROP COLUMN TaxDistrict,
DROP COLUMN propertyaddress,
DROP COLUMN row_nums;

-- Supprimer les lignes vides ou inutiles de 'data2'
-- Delete empty or unnecessary rows from 'data2'
SELECT * FROM data2 WHERE (Address IS NULL OR Address = "") AND OwnerName = "" AND OwnerSplitAddress = "";
DELETE FROM data2 WHERE (Address IS NULL OR Address = "") AND OwnerName = "" AND OwnerSplitAddress = "";

-- Vérifier les données finales dans 'data2'
-- Check the final data in 'data2'
SELECT * FROM data2;

-- Renommer la table 'data2' en 'clean_data_nashville'
-- Rename 'data2' table to 'clean_data_nashville'
RENAME TABLE data2 TO clean_data_nashville;
