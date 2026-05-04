/*
=============================================================================
  Project      : Nashville Housing Data Cleaning
  Description  : This script performs a series of data cleaning operations
                 on the NashvilleHousing dataset to improve data quality,
                 consistency, and usability for downstream analysis.
  Database     : DataCleaning(Nashville Housing)
  Schema       : dbo
  Table        : NashvilleHousing
  Author       : Maryam Rashid
=============================================================================

  Cleaning Steps:
    1. Standardize Sale Date format
    2. Populate missing Property Address values
    3. Split Property Address into separate columns (Address, City)
    4. Split Owner Address into separate columns (Address, City, State)
    5. Standardize 'SoldAsVacant' field values (Y/N -> Yes/No)
    6. Identify and remove duplicate records

=============================================================================
*/


-- =============================================================================
-- INITIAL DATA EXPLORATION
-- Preview all records in the dataset before any transformations
-- =============================================================================

SELECT * 
FROM [DataCleaning(Nashville Housing)].dbo.NashvilleHousing;


-- =============================================================================
-- STEP 1: Standardize Sale Date Format
-- The SaleDate column contains datetime values. We extract and store just
-- the date portion in a new column for cleaner, more consistent querying.
-- =============================================================================

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);


-- =============================================================================
-- STEP 2: Populate Missing Property Address Data
-- Some records are missing a PropertyAddress. Since properties sharing
-- the same ParcelID should have the same address, we use a self-join
-- to fill in the NULLs from matching ParcelID records.
-- =============================================================================

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [DataCleaning(Nashville Housing)].dbo.NashvilleHousing AS a
JOIN [DataCleaning(Nashville Housing)].dbo.NashvilleHousing AS b
    ON  a.ParcelID     =  b.ParcelID
    AND a.[UniqueID ]  <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- =============================================================================
-- STEP 3: Split Property Address into Separate Columns (Address, City)
-- The PropertyAddress column contains both street address and city,
-- separated by a comma. We split these into two dedicated columns
-- using SUBSTRING() and CHARINDEX() for better normalization.
-- =============================================================================

-- Add and populate the street address column
ALTER TABLE NashvilleHousing
ADD property_address NVARCHAR(255);

UPDATE NashvilleHousing
SET property_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Add and populate the city column 
ALTER TABLE NashvilleHousing
ADD propertycity NVARCHAR(255);

UPDATE NashvilleHousing
SET propertycity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- =============================================================================
-- STEP 4: Split Owner Address into Separate Columns (Address, City, State)
-- The OwnerAddress column contains street, city, and state separated by
-- commas. We use PARSENAME() with REPLACE() to split these into three
-- dedicated columns. PARSENAME reads right-to-left, so index 1 = state.
-- =============================================================================

-- Add and populate the owner state column
ALTER TABLE NashvilleHousing
ADD owner_state NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Add and populate the owner city column
ALTER TABLE NashvilleHousing
ADD owner_city NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

-- Add and populate the owner street address column
ALTER TABLE NashvilleHousing
ADD owner_address NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


-- =============================================================================
-- STEP 5: Standardize 'SoldAsVacant' Field Values
-- The SoldAsVacant column contains inconsistent values: 'Y', 'N', 'Yes', 'No'.
-- We normalize all entries to 'Yes' or 'No' using a CASE statement
-- to ensure consistency across the dataset.
-- =============================================================================

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;


-- =============================================================================
-- STEP 6: Remove Duplicate Records
-- We use a CTE with ROW_NUMBER() partitioned by key identifying fields
-- (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) to flag
-- duplicate rows. Records with row_num > 1 are considered duplicates.
--
-- NOTE: The SELECT below identifies duplicates for review.
--       To delete them, replace SELECT * with DELETE (commented out below).
-- =============================================================================

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM [DataCleaning(Nashville Housing)].dbo.NashvilleHousing
)
-- Review duplicates before deletion
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID;

-- To permanently remove duplicates, replace the SELECT above with:
-- DELETE FROM RowNumCTE WHERE row_num > 1;


-- =============================================================================
-- FINAL CHECK
-- Preview the fully cleaned dataset to verify all transformations
-- =============================================================================

SELECT * 
FROM [DataCleaning(Nashville Housing)].dbo.NashvilleHousing;