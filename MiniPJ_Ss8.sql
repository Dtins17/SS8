create database salesmanagement;
use salesmanagement;

create table category (
    category_id int auto_increment primary key,
    category_name varchar(100) not null unique
);

create table customer (
    customer_id int auto_increment primary key,
    full_name varchar(100) not null,
    gender tinyint(1),
    birth_date date,
    email varchar(100) unique,
    phone varchar(20) not null unique,
    address text,
    customer_type varchar(20)
);

create table product (
    product_id int auto_increment primary key,
    product_name varchar(200) not null,
    price decimal(15,2) not null check(price >= 0),
    stock_quantity int not null default 0,
    category_id int,
    constraint fk_product_category
    foreign key (category_id) references category(category_id)
);

create table orders (
    order_id int auto_increment primary key,
    order_date datetime default current_timestamp,
    customer_id int not null,
    total_amount decimal(15,2) default 0,
    status varchar(20),
    constraint fk_order_customer
    foreign key (customer_id) references customer(customer_id)
);

create table order_detail (
    order_id int not null,
    product_id int not null,
    quantity int not null check(quantity > 0),
    unit_price decimal(15,2) not null,
    primary key(order_id, product_id),
    constraint fk_detail_order
    foreign key (order_id) references orders(order_id),
    constraint fk_detail_product
    foreign key (product_id) references product(product_id)
);

insert into customer(full_name, gender, birth_date, email, phone, customer_type)
values
('Nguyen Van An', 1, '2000-05-10', 'an@gmail.com', '0901111111', 'vip'),
('Tran Thi Bich', 0, '1998-09-12', 'bich@gmail.com', '0902222222', 'normal'),
('Le Hoang Nam', 1, '2003-01-20', 'nam@gmail.com', '0903333333', 'vip'),
('Pham Thu Ha', 0, '1995-11-01', 'ha@gmail.com', '0904444444', 'normal'),
('Vo Minh Quan', 1, '2001-07-15', 'quan@gmail.com', '0905555555', 'normal');

insert into category(category_name)
values
('Dien tu'),
('Thoi trang'),
('Gia dung'),
('Sach'),
('My pham');

insert into product(product_name, price, stock_quantity, category_id)
values
('Laptop Asus', 25000000, 10, 1),
('Iphone 15', 30000000, 15, 1),
('Ao Hoodie', 500000, 50, 2),
('Noi chien khong dau', 2000000, 20, 3),
('Sach SQL', 150000, 100, 4),
('Son moi', 350000, 40, 5),
('Tai nghe Bluetooth', 1200000, 25, 1);

insert into orders(customer_id, order_date, status)
values
(1, '2026-05-01 10:00:00', 'completed'),
(2, '2026-05-02 14:30:00', 'completed'),
(1, '2026-05-03 09:15:00', 'cancelled'),
(3, '2026-05-04 16:20:00', 'completed'),
(4, '2026-05-05 11:45:00', 'completed');

insert into order_detail(order_id, product_id, quantity, unit_price)
values
(1, 1, 1, 25000000),
(1, 7, 2, 1200000),
(2, 3, 3, 500000),
(4, 2, 1, 30000000),
(5, 4, 1, 2000000);

update product
set price = 2200
where product_id = 1;

update customer
set email = 'newuseremail@gmail.com'
where customer_id = 1;

delete from order_detail
where order_id = 1
and product_id = 3;

delete from order_detail
where order_id = 5;

delete from orders
where order_id = 5;


select
    full_name as 'Ho Ten',
    email as 'Email',
    case
        when gender = 1 then 'Nam'
        else 'Nu'
    end as 'Gioi Tinh'
from customer;


select
    full_name,
    year(now()) - year(birth_date) as age
from customer
order by age asc
limit 3;


select
    o.order_id,
    c.full_name,
    o.order_date,
    o.status
from orders o
inner join customer c
on o.customer_id = c.customer_id;


select
    c.category_name,
    count(p.product_id) as total_product
from category c
inner join product p
on c.category_id = p.category_id
group by c.category_name
having count(p.product_id) >= 2;


select *
from product
where price >
(
    select avg(price)
    from product
);


select *
from customer
where customer_id not in
(
    select customer_id
    from orders
);

select
    c.category_name,
    sum(od.quantity * od.unit_price) as revenue
from category c
join product p on c.category_id = p.category_id
join order_detail od on p.product_id = od.product_id
group by c.category_name
having sum(od.quantity * od.unit_price) >
(
    select avg(total_revenue) * 1.2
    from
    (
        select sum(od.quantity * od.unit_price) as total_revenue
        from category c
        join product p on c.category_id = p.category_id
        join order_detail od on p.product_id = od.product_id
        group by c.category_name
    ) as temp
);

select *
from product p1
where price =
(
    select max(p2.price)
    from product p2
    where p1.category_id = p2.category_id
);

select full_name
from customer
where customer_type = 'vip'
and customer_id in
(
    select customer_id
    from orders
    where order_id in
    (
        select order_id
        from order_detail
        where product_id in
        (
            select product_id
            from product
            where category_id =
            (
                select category_id
                from category
                where category_name = 'Dien tu'
            )
        )
    )
);