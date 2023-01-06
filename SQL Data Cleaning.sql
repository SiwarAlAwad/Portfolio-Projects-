--Cleaning Data in SQL Queries 

select *
from [Portfolio Project]..NashvilleHousing

--Standardize Data Format

select SaleDateConverated,Convert(Date,SaleDate)
from [Portfolio Project]..NashvilleHousing
--Update NashvilleHousing
--set SaleDate=Convert(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverated Date;

Update NashvilleHousing
set SaleDateConverated = Convert(Date,SaleDate)



--Populate Property Address date

select PropertyAddress
from [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking Out Address into Individual Columns(Address,City,State)

select PropertyAddress
from [Portfolio Project]..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1,Charindex(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from [Portfolio Project]..NashvilleHousing

Alter table NashvilleHousing
Add ProperatySplitAddress Nvarchar(255);

Update NashvilleHousing
set ProperatySplitAddress = SUBSTRING(PropertyAddress, 1,Charindex(',',PropertyAddress)-1)

Alter table NashvilleHousing
Add ProperatySplitCity Nvarchar(255);

Update NashvilleHousing
set ProperatySplitCity = SUBSTRING(PropertyAddress,Charindex(',',PropertyAddress)+1,len(PropertyAddress))

Select *
from [Portfolio Project].dbo.NashvilleHousing


select OwnerAddress
from [Portfolio Project]..NashvilleHousing

select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from [Portfolio Project]..NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
from [Portfolio Project].dbo.NashvilleHousing


--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant),Count(SoldAsVacant)
from [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, Case when SoldAsVacant ='Y' then 'Yes'
       when SoldAsVacant ='N' then 'No'
	   else SoldAsVacant
	   End
from [Portfolio Project].dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant ='Y' then 'Yes'
       when SoldAsVacant ='N' then 'No'
	   else SoldAsVacant
	   End

--Remove Duplicates 

With RowNumberCTE As(
select *,
 ROW_NUMBER() over (
 partition by ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  legalReference
			  order by 
			  UniqueID
			  ) row_num
from [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumberCTE
where row_num >1 
order by PropertyAddress

-- Delete Unused Colums

select *
from [Portfolio Project].dbo.NashvilleHousing

Alter Table [Portfolio Project].dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress 

Alter Table [Portfolio Project].dbo.NashvilleHousing
drop column SaleDate 
