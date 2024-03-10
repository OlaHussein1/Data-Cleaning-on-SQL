
/*
Cleaning Data In SQL Queries
*/

Select*
From PortfolioProject.dbo.NashvilleHousing 

----------------------------------------------------------------------------------------------

--Standardize Data Format

Select SaleDateConverted, Convert (Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing 

UPDATE NashvilleHousing
SET SaleDate = Convert (Date,SaleDate) 

Alter Table NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = Convert (Date,SaleDate) 

------------------------------------------------------------------

-- Populate Property Address Date 

Select*
From PortfolioProject.dbo.NashvilleHousing 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
Join PortfolioProject.dbo.NashvilleHousing B  
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing A
Join PortfolioProject.dbo.NashvilleHousing B  
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress IS NULL 

---------------------------------------------------------------

--Breaking out Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing 
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID 

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
From PortfolioProject.dbo.NashvilleHousing 

Alter Table NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
ADD PropertySplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioProject..NashvilleHousing


Alter Table NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table NashvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitState = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant 
ORDER BY 2 

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END 

  ---------------------------------------------------------------------------------------------------

  -- Remove Duplicates

  WITH RowNumCTE AS(
  SELECT*,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
			) Row_Num


  FROM PortfolioProject..NashvilleHousing
  --ORDER BY ParcelID
  )
  DELETE
  FROM RowNumCTE
  WHERE Row_Num >1
  --ORDER BY PropertyAddress

  --------------------------------------------------------------------------------------

  --DELETE UNUSED COLUMNS

  SELECT*
  FROM PortfolioProject..NashvilleHousing 

  ALTER TABLE PortfolioProject..NashvilleHousing 
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

    ALTER TABLE PortfolioProject..NashvilleHousing 
  DROP COLUMN SaleDate