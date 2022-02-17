
--Change data type of SaleDate(Datetime to Date)
select SaleDate, CAST(SaleDate as Date)
from PortfolioProject.dbo.NashVilleHousing

alter table NashVilleHousing
alter column SaleDate Date; 

-- Handling PropertyAddress null
select *
from PortfolioProject.dbo.NashVilleHousing
where PropertyAddress is null

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
from PortfolioProject.dbo.NashVilleHousing A
join PortfolioProject.dbo.NashVilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
set PropertyAddress = isnull(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject.dbo.NashVilleHousing A
join PortfolioProject.dbo.NashVilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

-- Split Address to Street, City
select PropertyAddress, 
left(PropertyAddress,CHARINDEX(',', PropertyAddress) - 1),
right(PropertyAddress,len(PropertyAddress) - CHARINDEX(',', PropertyAddress) - 1)
from PortfolioProject.dbo.NashVilleHousing

alter table NashVilleHousing
add PropertyAddStreet nvarchar(255), 
	PropertyAddCity nvarchar(255);

update NashVilleHousing
set PropertyAddStreet = left(PropertyAddress,CHARINDEX(',', PropertyAddress) - 1),
	PropertyAddCity = right(PropertyAddress,len(PropertyAddress) - CHARINDEX(',', PropertyAddress) - 1)

-- Split OnwerAddress to Street, City and State
select OwnerAddress, 
left(OwnerAddress,CHARINDEX(',', OwnerAddress) - 1),
left(right(OwnerAddress,len(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 1),CHARINDEX(',', right(OwnerAddress,len(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 1)) - 1),
right(right(OwnerAddress,len(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 1),len(right(OwnerAddress,len(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 1)) - CHARINDEX(',', right(OwnerAddress,len(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 1)) - 1)
from PortfolioProject.dbo.NashVilleHousing

alter table NashVilleHousing
add OwnerAddStreet nvarchar(255), 
	OwnerAddCity nvarchar(255), 
	OwnerAddState nvarchar(255)

update NashVilleHousing
set OwnerAddStreet = left(OwnerAddress,CHARINDEX(',', OwnerAddress) - 1)
	
update NashVilleHousing
set OwnerAddCity =  left(A, CHARINDEX(',', A)-1) 
from (select RIGHT(OwnerAddress, len(OwnerAddress)- CHARINDEX(',', OwnerAddress)-1) as A
		from NashVilleHousing) as B
	
update NashVilleHousing
set OwnerAddState =  right(A, len(A) - CHARINDEX(',', A) - 1) 
from (select right(OwnerAddress,len(OwnerAddress) - CHARINDEX(',', OwnerAddress) - 1) as A
		from NashVilleHousing) as B

-- Change Y and N to Yes and No in SoldAsVacant column
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashVilleHousing
group by SoldAsVacant 

update NashVilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant
					end

-- Remove duplicate rows
with cte as (
select *, ROW_NUMBER () over (partition by ParcelID, SalePrice, LegalReference, SaleDate, PropertyAddress ORDER BY ParcelID) as row_num_col
from PortfolioProject.dbo.NashVilleHousing
)
delete
from cte
where row_num_col > 1
--order by ParcelID

--Handing data inconsistent(VACANT RESIENTIAL LAND, VACANT RES LAND, VACANT RESIDENTIAL LAND)
select distinct(LandUse)
from PortfolioProject.dbo.NashVilleHousing

update NashVilleHousing
set LandUse = case when LandUse in ('VACANT RESIENTIAL LAND', 'VACANT RES LAND') then 'VACANT RESIDENTIAL LAND'
					else LandUse
					end
from PortfolioProject.dbo.NashVilleHousing

-- Remove unuseful columns
alter table NashVilleHousing
drop column PropertyAddress, OwnerAddress