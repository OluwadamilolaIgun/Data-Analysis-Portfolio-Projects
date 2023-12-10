/*

CLEANING DATA IN SQL

*/

Select*
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------

---Date Formatting

Select SaleDateConverted, CONVERT (Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

---------------------------------------------------------

----------------Filling Property Addresss Data (Clearing Null Values)
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is Null
Order by ParcelID
---


Select x.ParcelID, x.PropertyAddress, y.ParcelID, y.PropertyAddress, ISNULL(x.PropertyAddress, y.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing x
JOIN PortfolioProject.dbo.NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress is null


UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing x
JOIN PortfolioProject.dbo.NashvilleHousing y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]


----------------------
---Splitting Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is Null


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyAddressSplit Nvarchar(260);

Update NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(260);

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))



Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerAddressSplit Nvarchar(260);

Update NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerCitySplit Nvarchar(260);

Update NashvilleHousing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(260);

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---------------
----Change Y and N to Yes and No in the field "Sold as Vacant"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing



---------------------------------------------------------------
--------REMOVE DUPLICATES


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)


DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress
----------------------------------------------------------------
----Deleting Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

