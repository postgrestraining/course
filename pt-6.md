### IN

```
select outerUsers.uid,
       outerUsers.givenname,
       outerUsers.surname,
       outerUsers.city,
       outerSales.selling_price,
       outerSales.payed
from sales outerSales
         join users outerUsers on outerSales.users_id = outerUsers.id
where users_id in ( -- instead of 'column in' use exists and ...
    select innerUsers.id
    from users innerUsers
             join sales innerSales on innerUsers.id = innerSales.users_id
             join products innerProducts on innerSales.products_id = innerProducts.id
    where (innerProducts.cost > 10
      and innerSales.payed < innerSales.selling_price
      and outerUsers.id = outerSales.users_id)
      -- add a backlink to the original column: and outerSales.users_id = innerSales.users_id
)
  and outerUsers.city = '10_city'
  limit 500
;
```

### EXISTS

```
select outerUsers.uid,
       outerUsers.givenname,
       outerUsers.surname,
       outerUsers.city,
       outerSales.selling_price,
       outerSales.payed
from sales outerSales
         join users outerUsers on outerSales.users_id = outerUsers.id
where exists(  -- this line was changed from in to exists
        select innerUsers.id
        from users innerUsers
                 join sales innerSales on innerUsers.id = innerSales.users_id
                 join products innerProducts on innerSales.products_id = innerProducts.id
        where (innerProducts.cost > 10
          and innerSales.payed < innerSales.selling_price
          and outerUsers.id = outerSales.users_id)
          and outerSales.users_id = innerSales.users_id -- and this backlink was added
    )
  and outerUsers.city = '10_city'
  limit 500
;
```
