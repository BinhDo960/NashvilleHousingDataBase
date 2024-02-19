--Cleaning Data in SQL Queries

Select *
From NashVilleHousingDB.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashVilleHousingDB.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From NashVilleHousingDB.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashVilleHousingDB.dbo.NashvilleHousing a
JOIN NashVilleHousingDB.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashVilleHousingDB.dbo.NashvilleHousing a
JOIN NashVilleHousingDB.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashVilleHousingDB.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From NashVilleHousingDB.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashVilleHousingDB.dbo.NashvilleHousing

Select OwnerAddress
From NashVilleHousingDB.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',', '.'),3),
PARSENAME(Replace(OwnerAddress,',', '.'),2),
PARSENAME(Replace(OwnerAddress,',', '.'),1)
From NashVilleHousingDB.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity varchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState varchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)


------------------------------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashVilleHousingDB.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
From NashVilleHousingDB.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
	) row_num

From NashVilleHousingDB.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--DELETE
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress


------------------------------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

Select *
From NashVilleHousingDB.dbo.NashvilleHousing

ALTER TABLE NashVilleHousingDB.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashVilleHousingDB.dbo.NashvilleHousing
DROP COLUMN SaleDate

