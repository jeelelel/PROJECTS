--a) The number of visits by season and by pet types,
--by season
select season_code, sum(num_visit) as total_visit_per_season 
from pet9_dw_fact
group by season_code;

--by pet type
select distinct(pd.pet_type), sum(p.num_visit) as total_visit_per_pet_type 
from pet9_dw_fact p , pet_dim pd
where p.pet_id = pd.pet_id
group by pd.pet_type;

--b) The number of visits handled by different levels of staff expertise,
select distinct(s.staff_level), s.staff_expertise, sum(p.num_visit) as total_visit_per_staff_expertise 
from pet9_dw_fact p , staff_dim s
where p.staff_id = s.staff_id
group by s.staff_level, s.staff_expertise
order by s.staff_level, s.staff_expertise;

--c) The number of visits by different products,
select distinct(pr.product_id), sum(p.num_visit) as total_visit_per_different_product
from pet9_dw_fact p , product_dim pr, bridgetable bt
where bt.service_id = p.service_id and
bt.product_id = pr.product_id
group by pr.product_id
order by pr.product_id;

--d) The total income by services, for different pet types, and
select distinct(s.service_id),
pd.pet_type,
sum(p.total_income) as total_service_income
from pet9_dw_fact p , service_dim s, bridgetable bt, pet_dim pd
where bt.service_id = s.service_id and p.pet_id = pd.pet_id
group by s.service_id, pd.pet_type
order by s.service_id;

--e) The total income by different products.
select distinct(pr.product_id), sum(p.total_income) as total_income_by_different_product
from pet9_dw_fact p , product_dim pr, bridgetable bt
where bt.service_id = p.service_id and
bt.product_id = pr.product_id
group by pr.product_id
order by pr.product_id;
