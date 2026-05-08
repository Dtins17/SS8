create database if not exists salesmanagement;
use salesmanagement;

create table if not exists categorys (
    category_id int auto_increment primary key,
    category_name varchar(100) not null unique
);

create table if not exists customers (
    customer_id int auto_increment primary key,
    full_name varchar(100) not null,
    gender tinyint check (gender in (0,1)),
    birth_date date,
    email varchar(100) unique,
    phone varchar(20) not null unique,
    address text,
    customer_type varchar(20)
);

create table if not exists products (
    product_id int auto_increment primary key,
    product_name varchar(200) not null,
    price decimal(15,2) not null check(price >= 0),
    stock_quantity int not null default 0,
    category_id int,
    constraint fk_product_category
    foreign key (category_id) references categorys(category_id)
);

create table if not exists orders (
    order_id int auto_increment primary key,
    order_date datetime default current_timestamp,
    customer_id int not null,
    total_amount decimal(15,2) default 0,
    status varchar(20) check(status in ('completed','cancelled')),
    constraint fk_order_customer
    foreign key (customer_id) references customers(customer_id)
);

create table if not exists order_detail (
    order_id int not null,
    product_id int not null,
    quantity int not null check(quantity > 0),
    unit_price decimal(15,2) not null,
    primary key(order_id, product_id),
    constraint fk_detail_order
    foreign key (order_id) references orders(order_id),
    constraint fk_detail_product
    foreign key (product_id) references products(product_id)
);

insert into customers(full_name, gender, birth_date, email, phone, customer_type) values
('Nguyen Van An', 1, '2000-05-10', 'an@gmail.com', '0901111111', 'vip'),
('Tran Thi Bich', 0, '1998-09-12', 'bich@gmail.com', '0902222222', 'normal'),
('Le Hoang Nam', 1, '2003-01-20', 'nam@gmail.com', '0903333333', 'vip'),
('Pham Thu Ha', 0, '1995-11-01', 'ha@gmail.com', '0904444444', 'normal'),
('Vo Minh Quan', 1, '2001-07-15', 'quan@gmail.com', '0905555555', 'normal');

insert into categorys(category_name) values
('Dien tu'),
('Thoi trang'),
('Gia dung'),
('Sach'),
('My pham');

insert into products(product_name, price, stock_quantity, category_id) values
('Laptop Asus', 25000000, 10, 1),
('Iphone 15', 30000000, 15, 1),
('Ao Hoodie', 500000, 50, 2),
('Noi chien khong dau', 2000000, 20, 3),
('Sach SQL', 150000, 100, 4),
('Son moi', 350000, 40, 5),
('Tai nghe Bluetooth', 1200000, 25, 1);

insert into orders(customer_id, order_date, status) values
(1, '2026-05-01 10:00:00', 'completed'),
(2, '2026-05-02 14:30:00', 'completed'),
(1, '2026-05-03 09:15:00', 'cancelled'),
(3, '2026-05-04 16:20:00', 'completed'),
(4, '2026-05-05 11:45:00', 'completed');

insert into order_detail(order_id, product_id, quantity, unit_price) values
(1, 1, 1, 25000000),
(1, 7, 2, 1200000),
(2, 3, 3, 500000),
(4, 2, 1, 30000000),
(5, 4, 1, 2000000);

update products
set price = 22000000
where product_id = 1;

update customers
set email = 'newuseremail@gmail.com'
where customer_id = 1;

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
from customers;

select
    full_name,
    timestampdiff(year, birth_date, now()) as age
from customers
order by age asc
limit 3;

select
    o.order_id,
    c.full_name,
    o.order_date,
    o.status
from orders o
join customers c
on o.customer_id = c.customer_id;

select
    c.category_name,
    count(p.product_id) as total_product
from categorys c
join products p on c.category_id = p.category_id
group by c.category_name
having count(p.product_id) >= 2;

select *
from products
where price > (select avg(price) from products);

select *
from customers c
where not exists (
    select 1
    from orders o
    where o.customer_id = c.customer_id
);

select
    c.category_name,
    sum(od.quantity * od.unit_price) as revenue
from categorys c
join products p on c.category_id = p.category_id
join order_detail od on p.product_id = od.product_id
join orders o on o.order_id = od.order_id
where o.status = 'completed'
group by c.category_name
having sum(od.quantity * od.unit_price) >
(
    select avg(total_revenue) * 1.2
    from (
        select sum(od.quantity * od.unit_price) as total_revenue
        from categorys c
        join products p on c.category_id = p.category_id
        join order_detail od on p.product_id = od.product_id
        join orders o on o.order_id = od.order_id
        where o.status = 'completed'
        group by c.category_name
    ) as temp
);

select *
from products p1
where price = (
    select max(p2.price)
    from products p2
    where p1.category_id = p2.category_id
);

select distinct c.full_name
from customers c
join orders o on c.customer_id = o.customer_id
join order_detail od on o.order_id = od.order_id
join products p on od.product_id = p.product_id
join categorys ca on p.category_id = ca.category_id
where c.customer_type = 'vip'
and ca.category_name = 'Dien tu';