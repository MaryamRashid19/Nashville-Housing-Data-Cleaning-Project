# 🏠 Nashville Housing Data Cleaning (SQL)

## Project Overview
This project focuses on cleaning and transforming raw Nashville Housing data 
using SQL Server. The goal is to prepare the dataset for reliable analysis 
by fixing common data quality issues.

## Dataset
- **Source:** Nashville Housing public property sales data
- **Records:** 56,000+ rows of property transaction data
- **Tool Used:** Microsoft SQL Server (T-SQL)

## Data Cleaning Steps Performed

### 1. Standardized Date Format
Converted the `SaleDate` column from a datetime format to a clean `DATE` type
using `CONVERT()` and stored it in a new column `SaleDateConverted`.

### 2. Populated Missing Property Addresses
Used a self-join on `ParcelID` to fill in NULL `PropertyAddress` values,
since properties sharing the same Parcel ID share the same address.

### 3. Split Address into Individual Columns
- Split `PropertyAddress` into `property_address` and `propertycity`
  using `SUBSTRING()` and `CHARINDEX()`.
- Split `OwnerAddress` into `owner_address`, `owner_city`, and `owner_state`
  using `PARSENAME()` and `REPLACE()`.

### 4. Standardized 'SoldAsVacant' Field
Replaced inconsistent `Y`/`N` values with `Yes`/`No` using a `CASE` statement.

### 5. Removed Duplicate Records
Used a CTE with `ROW_NUMBER()` partitioned by key fields 
(ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference) 
to identify and remove duplicate rows.

## Key SQL Concepts Used
- `ALTER TABLE` / `UPDATE`
- `SUBSTRING()`, `CHARINDEX()`, `PARSENAME()`
- `ISNULL()` with self-joins
- `CASE` statements
- CTEs with `ROW_NUMBER()` and `PARTITION BY`

## Files
| File | Description |
|------|-------------|
| `nashville_housing_data_cleaning.sql` | Main SQL cleaning script |
| `data/nashville_housing_raw.csv` | Raw dataset |