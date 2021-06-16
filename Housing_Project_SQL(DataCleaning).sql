
--QUERIES PERFORMED TO CLEAN DATASET:
---Q. Standardize Date Format.
---Q. Populating the blank Property Addresses by reference to ParcelId.
---Q. Separating Addresses into Address & City.
---Q. 'Sold As Vacant' column has NON-Standardized Cells,Making it Yes/No where its 'Y' or 'N'.
---Q. Removing Duplicate Entries from Dataset.
---Q. Deleting Columns that are not needed to perform Analysis.

------------------------------------------------------------------------------------------------------------------------

--Observing Data 
Select top 5*
from PortfolioProjects.dbo.Housing_Data

--------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format:
--Checking if function works:
Select SaleDate,Convert(date,SaleDate) as Sale_Date
from PortfolioProjects..Housing_Data

--Adding Standardized Date Column:
Alter Table Housing_Data
Add Sale_Date date;

Update Housing_Data
Set Sale_Date = Convert(date,SaleDate) 

Select Sale_Date
From Housing_Data



----------------------------------------------------------------------------------------------------------------------------
--Looking at the Data we Observed that Some Property Address are not populated (i.e They are null)
--By Observation , it came out that Parcel ID is the same for Same Property Address.

----Populating the blank Property Addresses by reference to ParcelId:
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects..Housing_Data a
join PortfolioProjects..Housing_Data b
    on a.ParcelID=b.ParcelID
    and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--We got our result now we can update it:
Update a
    Set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
    from PortfolioProjects..Housing_Data a
    join PortfolioProjects..Housing_Data b
        on a.ParcelID=b.ParcelID
        and a.[UniqueID ]<>b.[UniqueID ]
    where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------
--Separating Address String
--As we can see that the Address is in one Single Line,the Address needs to be separated after the delimiter(','):
Select PropertyAddress,
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as First_Add_line,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Second_Add_line
from PortfolioProjects..Housing_Data

--To make the changes in our Table:
Alter Table PortfolioProjects..Housing_Data
 Add
 First_Add_line nvarchar(255),
 Second_Add_line nvarchar(255)

Update Housing_Data
    Set
    First_Add_line=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
Update Housing_Data
    Set
    Second_add_line=Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--Separating the OwnerAddress(Using ParseName):
Select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3) ,
PARSENAME(Replace(OwnerAddress,',','.'),2) ,
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProjects..Housing_Data

--Making Change Permanent:
Alter Table PortfolioProjects..Housing_Data
 Add
 Owner_Add1 nvarchar(255),
 Owner_Add2 nvarchar(255),
 Owner_Add3 nvarchar(255)

Update Housing_Data
    Set Owner_Add1 = PARSENAME(Replace(OwnerAddress,',','.'),3)
Update Housing_Data
    Set Owner_Add2 = PARSENAME(Replace(OwnerAddress,',','.'),2)
Update Housing_Data
    Set Owner_Add3 = PARSENAME(Replace(OwnerAddress,',','.'),1)



-----------------------------------------------------------------------------------------------
--'Sold As Vacant' column has NON-Standardized Cells:
Select Distinct(SoldAsVacant)
From PortfolioProjects..Housing_Data
--Noted that 4 unique values in the column(YES,NO,Y,N);
--Making it Yes/No in place of 'Y' or 'N':

Select SoldAsVacant,
Case
    When SoldAsVacant='Y' Then 'Yes'
	When SoldAsVacant='N' Then 'No'
	Else SoldAsVacant
End
From PortfolioProjects..Housing_Data

--Making Change Permanent:
UPDATE PortfolioProjects..Housing_Data
Set
   SoldAsVacant=Case
                     When SoldAsVacant='Y' Then 'Yes'
	                 When SoldAsVacant='N' Then 'No'
	                 Else SoldAsVacant
                End

Select Distinct(SoldAsVacant)
From PortfolioProjects..Housing_Data


----------------------------------------------------------------------------------------------
--Removing Duplicate Entries from Dataset: 
Select*,
ROW_NUMBER() over 
(PARTITION BY ParcelID,
              PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference,
			  Acreage,
			  LandValue,
			  YearBuilt
 order by UniqueId  )
From PortfolioProjects..Housing_Data
Order By ParcelID
---Here all entries that have Row no. more than 1 is a Duplicate Entry.

--Drop All Duplicate Entries.

With Housing_CTE as
( 
 Select *,
 ROW_NUMBER() over 
(PARTITION BY ParcelID,
              PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference,
			  Acreage,
			  LandValue,
			  YearBuilt
 order by UniqueId  ) Row_num
 From PortfolioProjects..Housing_Data
)
DELETE
From Housing_CTE
Where Row_num > 1


--------------------------------------------------------------------------------------------
--Deleting Columns that are not needed to perform Analysis:

Alter Table PortfolioProjects..Housing_Data
Drop Column OwnerAddress,
            PropertyAddress,
			TaxDistrict
Alter Table PortfolioProjects..Housing_Data
Drop Column SaleDate

--------------------------------------------------------------------------------------------
--Checking the New Cleaned Data:
Select*
From PortfolioProjects..Housing_Data
			









 




