--Select from all to ensure everything is working
Select * from
Nashville_Housing_Data..NashvilleHousingData

-- Changing data format (from date-time format to  date)
Select SaleDate, convert(Date,SaleDate) from
Nashville_Housing_Data..NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date

Update NashvilleHousingData
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted, convert(Date,SaleDate) from
Nashville_Housing_Data..NashvilleHousingData

-- Populating Missing Data in Property Address
Select *
from Nashville_Housing_Data..NashvilleHousingData
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing_Data..NashvilleHousingData a 
join Nashville_Housing_Data..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing_Data..NashvilleHousingData a 
join Nashville_Housing_Data..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null
--Now run the above select query again to ensure that no null values appear

-- Separating Address into multiple columns (Address, City, State) using substrings
Select PropertyAddress
From Nashville_Housing_Data..NashvilleHousingData

SELECT SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From Nashville_Housing_Data..NashvilleHousingData

ALTER TABLE Nashville_Housing_Data..NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing_Data..NashvilleHousingData
SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nashville_Housing_Data..NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing_Data..NashvilleHousingData
SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select * from
Nashville_Housing_Data..NashvilleHousingData
--Check to see new columns and if they look realistic


--Using ParseName function to clean OwnerAddress
Select OwnerAddress
from Nashville_Housing_Data..NashvilleHousingData

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from Nashville_Housing_Data..NashvilleHousingData

ALTER TABLE Nashville_Housing_Data..NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing_Data..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_Housing_Data..NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing_Data..NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville_Housing_Data..NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing_Data..NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



-- Changing the Y and N values to Yes and No in the "Sold as Vacant" column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing_Data..NashvilleHousingData
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nashville_Housing_Data..NashvilleHousingData
-- Else statement keeps everything the same if it is not a 'Y' or 'N' value

Update Nashville_Housing_Data..NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Removing the duplicates in our dataset
-- We are partitioning by columns that should be unique in each row

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

From Nashville_Housing_Data..NashvilleHousingData
)
DELETE 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Checking and confirming that duplicates from previous query were deleted
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

From Nashville_Housing_Data..NashvilleHousingData
)
Select * 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From Nashville_Housing_Data..NashvilleHousingData

-- Deleting Unused Columns, simple alter and drop column command
Select *
From Nashville_Housing_Data..NashvilleHousingData


ALTER TABLE Nashville_Housing_Data..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate