/*

Cleaning Data in SQL Queries

*/

select * from PortfolioProject..NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


--Select saleDate,
--		CONVERT(Date,SaleDate)
--From PortfolioProject.dbo.NashvilleHousing;
--Not working properly
--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

Alter table NashvilleHousing
add saleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing;

select propertyaddress,
		SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
		SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress)) as city

	from PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add propertysplitaddress nvarchar(255);

update NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1);

alter table NashvilleHousing
add propertysplitcity nvarchar(255);

update NashvilleHousing
set propertysplitcity = SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress));

--Owner Address
select OwnerAddress,
		PARSENAME(REPLACE(owneraddress,',','.'),3),
		PARSENAME(REPLACE(owneraddress,',','.'),2),
		PARSENAME(REPLACE(owneraddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing;

alter table NashvilleHousing
add Ownersplitaddress nvarchar(255);

update NashvilleHousing
set Ownersplitaddress = PARSENAME(REPLACE(owneraddress,',','.'),3);

alter table NashvilleHousing
add ownersplitcity nvarchar(255);

update NashvilleHousing
set ownersplitcity = PARSENAME(REPLACE(owneraddress,',','.'),2);

alter table NashvilleHousing
add ownersplitstate nvarchar(255);

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress,',','.'),1);


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), 
		Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2;

select soldasvacant,
		case 
			when soldasvacant = 'N' then 'No'
			when soldasvacant = 'Y' then 'Yes'
			else soldasvacant
		end
	From PortfolioProject.dbo.NashvilleHousing
	--where soldasvacant = 'N'

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
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

)

--delete
--From RowNumCTE
--Where row_num > 1


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

