-- общее количество клиентов
select count (distinct card)
from bonuscheques
where card like '2000%'

-- rfm-перцентили
with tmp as (
    select
        card,
        '2022-06-09'::date - max(datetime)::date as recency,
        count(datetime) as frequency,
        sum(summ_with_disc) as monetary
    from bonuscheques
    where card like '2000%'
    group by card
)
select
min('recency') as показатель,
percentile_disc(0.33) within group(order by recency) as perc_33,
percentile_disc(0.66) within group(order by recency) as perc_66
from tmp
union
select
min('frequency'),
percentile_disc(0.33) within group(order by frequency),
percentile_disc(0.66) within group(order by frequency)
from tmp
union
select
min('monetary'),
percentile_disc(0.33) within group (order by monetary) as perc_33,
percentile_disc(0.66) within group (order by monetary) as perc_66
from tmp

-- rfm
with tmp as (
    select
        card,
        '2022-06-09'::date - max(datetime)::date as recency,
        count(datetime) as frequency,
        sum(summ_with_disc) as monetary
    from bonuscheques
    where card like '2000%'
    group by card
), tmp2 as (
    select
    card,
    case 
        when recency <= 48 then '3'
        when recency > 143 then '1'
        else '2' end as recency_group,
    case
        when frequency > 3 then '3'
        when frequency = 1 then '1'
        else '2' end as frequency_group,
    case
        when monetary > 2400 then '3'
        when monetary <=900 then '1'
        else '2' end as monetary_group
    from tmp
)
select
    count(card),
    concat(recency_group, frequency_group, monetary_group) as rfm_group
from tmp2
group by rfm_group
order by count(card) desc