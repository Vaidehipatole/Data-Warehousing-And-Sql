use housing_inspection_data;

Select * from public_housing_inspection_data;

UPDATE `public_housing_inspection_data` SET `INSPECTION_DATE` = STR_TO_DATE( `INSPECTION_DATE`, '%m/%d/%Y');
select * from public_housing_inspections_data;

## removing all the agencies that performed inspections only once
select PUBLIC_HOUSING_AGENCY_NAME ,count(*) from public_housing_inspection_data
group by public_housing_agency_name
having count(*) >1
order by PUBLIC_HOUSING_AGENCY_NAME;
##


select b.PUBLIC_HOUSING_AGENCY_NAME  ,b.INSPECTION_DATE ,b.COST_OF_INSPECTION_IN_DOLLARS,
lead(b.COST_OF_INSPECTION_IN_DOLLARS) over (partition by b.PUBLIC_HOUSING_AGENCY_NAME order by b.PUBLIC_HOUSING_AGENCY_NAME,b.INSPECTION_DATE  ) as recent_cost
from public_housing_inspection_data b join (select PUBLIC_HOUSING_AGENCY_NAME,count(*) as counts
from public_housing_inspection_data
group by PUBLIC_HOUSING_AGENCY_NAME
having counts >1) a on a.PUBLIC_HOUSING_AGENCY_NAME= b.PUBLIC_HOUSING_AGENCY_NAME;

create table one1 as 
select b.PUBLIC_HOUSING_AGENCY_NAME as PHA_NAME  ,
b.INSPECTION_DATE as MR_INSPECTION_DATE ,
b.COST_OF_INSPECTION_IN_DOLLARS as MR_INSPECTION_COST,
lead(b.INSPECTION_DATE) over (partition by b.PUBLIC_HOUSING_AGENCY_NAME order by b.PUBLIC_HOUSING_AGENCY_NAME,b.INSPECTION_DATE desc  ) as SECOND_MR_INSPECTION_DATE, 
lead(b.COST_OF_INSPECTION_IN_DOLLARS) over (partition by b.PUBLIC_HOUSING_AGENCY_NAME order by b.PUBLIC_HOUSING_AGENCY_NAME,b.INSPECTION_DATE desc  ) as SECOND_MR_INSPECTION_COST,
b.COST_OF_INSPECTION_IN_DOLLARS-(lead(b.COST_OF_INSPECTION_IN_DOLLARS) over (partition by b.PUBLIC_HOUSING_AGENCY_NAME order by b.PUBLIC_HOUSING_AGENCY_NAME,b.INSPECTION_DATE desc))  as CHANGE_IN_COST,
((b.COST_OF_INSPECTION_IN_DOLLARS-(lead(b.COST_OF_INSPECTION_IN_DOLLARS) over (partition by b.PUBLIC_HOUSING_AGENCY_NAME order by b.PUBLIC_HOUSING_AGENCY_NAME,b.INSPECTION_DATE desc)))/(lead(b.COST_OF_INSPECTION_IN_DOLLARS) over
(partition by b.PUBLIC_HOUSING_AGENCY_NAME order by b.PUBLIC_HOUSING_AGENCY_NAME,b.INSPECTION_DATE desc)))*100 as percent_CHANGE_IN_COST
from public_housing_inspection_data b join (select PUBLIC_HOUSING_AGENCY_NAME,count(*) as counts
from public_housing_inspection_data
group by PUBLIC_HOUSING_AGENCY_NAME
having counts >1) a on a.PUBLIC_HOUSING_AGENCY_NAME= b.PUBLIC_HOUSING_AGENCY_NAME;


select * from one1;
create table two_2 as
select PHA_NAME,MR_INSPECTION_DATE,MR_INSPECTION_COST,SECOND_MR_INSPECTION_DATE,SECOND_MR_INSPECTION_COST,CHANGE_IN_COST, percent_CHANGE_IN_COST
, row_number() over(partition by PHA_NAME) 
as flag from one1 ;

select * from two_2;

select * from two_2  where flag=1 and CHANGE_IN_COST >0;