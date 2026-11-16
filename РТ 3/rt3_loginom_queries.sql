-- РТ 3. SQL-запросы для узла «База данных» в Loginom (подключение к pizza_orders.db).
-- Копируй по одному запросу в узел, выполняй, снимай скриншот «узел + таблица результата».
-- Минимум для отчёта: задачи 1, 7, 8, 11, 13, 14 (под них уже есть места в отчёте).

-- ===== Задача 1. HAVING: категории с 8 и более видами пицц =====
SELECT c.category_name, COUNT(*) AS pizza_count
FROM pizza p
JOIN category c ON p.category_id = c.category_id
GROUP BY c.category_name
HAVING COUNT(*) >= 8;

-- ===== Задача 2. Имена таблиц и их CREATE-запросы =====
SELECT name, sql FROM sqlite_schema WHERE type = 'table' ORDER BY name;

-- ===== Задача 3. Названия пицц и ингредиенты =====
SELECT pizza_name, pizza_ingredients FROM pizza;

-- ===== Задача 4. Пиццы Veggie или Chicken =====
SELECT p.pizza_name, c.category_name, p.pizza_ingredients
FROM pizza p
JOIN category c ON p.category_id = c.category_id
WHERE c.category_name IN ('Veggie', 'Chicken')
ORDER BY c.category_name, p.pizza_name;

-- ===== Задача 5. Пиццы с Mozzarella Cheese =====
SELECT p.pizza_name, c.category_name, p.pizza_ingredients
FROM pizza p
JOIN category c ON p.category_id = c.category_id
WHERE p.pizza_ingredients LIKE '%Mozzarella Cheese%';

-- ===== Задача 6. Заказы апр(вкл)–авг(невкл) 2015, время 13:00–17:00 =====
SELECT order_id, datetime(order_datetime) AS order_dt
FROM orders
WHERE date(order_datetime) >= '2015-04-01'
  AND date(order_datetime) <  '2015-08-01'
  AND time(order_datetime) BETWEEN '13:00:00' AND '17:00:00'
ORDER BY order_datetime;

-- ===== Задача 7. Топ-10 заказов по числу купленных пицц =====
SELECT o.order_id, SUM(od.quantity) AS total_pizzas
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id
ORDER BY total_pizzas DESC
LIMIT 10;

-- ===== Задача 8. Дата и время 10 заказов с наибольшим числом пицц =====
SELECT date(o.order_datetime) AS order_date,
       time(o.order_datetime) AS order_time,
       SUM(od.quantity)       AS total_pizzas
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_id
ORDER BY total_pizzas DESC, order_date ASC, order_time ASC
LIMIT 10;

-- ===== Задача 9. Полное меню ресторана с ценами =====
SELECT p.pizza_name, s.size_name, ps.unit_price,
       c.category_name, p.pizza_ingredients
FROM pizza_size ps
JOIN pizza p    ON ps.pizza_id = p.pizza_id
JOIN size  s    ON ps.size_id  = s.size_id
JOIN category c ON p.category_id = c.category_id;

-- ===== Задача 10. Позиции, покупавшиеся не по 1 шт (quantity != 1) =====
SELECT p.pizza_name, s.size_name, COUNT(*) AS times
FROM order_details od
JOIN pizza_size ps ON od.pizza_size_id = ps.pizza_size_id
JOIN pizza p       ON ps.pizza_id = p.pizza_id
JOIN size  s       ON ps.size_id  = s.size_id
WHERE od.quantity != 1
GROUP BY od.pizza_size_id
ORDER BY times DESC;

-- ===== Задача 11. Полная таблица транзакций + total_price =====
SELECT o.order_id,
       date(o.order_datetime) AS purchase_date,
       time(o.order_datetime) AS purchase_time,
       p.pizza_name, s.size_name, c.category_name,
       od.quantity, ps.unit_price,
       ROUND(ps.unit_price * od.quantity, 2) AS total_price
FROM order_details od
JOIN orders o      ON od.order_id = o.order_id
JOIN pizza_size ps ON od.pizza_size_id = ps.pizza_size_id
JOIN pizza p       ON ps.pizza_id = p.pizza_id
JOIN size  s       ON ps.size_id  = s.size_id
JOIN category c    ON p.category_id = c.category_id;

-- ===== Задача 12. Представление (VIEW) на запрос из задачи 11 =====
CREATE VIEW full_transactions AS
SELECT o.order_id,
       date(o.order_datetime) AS purchase_date,
       time(o.order_datetime) AS purchase_time,
       p.pizza_name, s.size_name, c.category_name,
       od.quantity, ps.unit_price,
       ROUND(ps.unit_price * od.quantity, 2) AS total_price
FROM order_details od
JOIN orders o      ON od.order_id = o.order_id
JOIN pizza_size ps ON od.pizza_size_id = ps.pizza_size_id
JOIN pizza p       ON ps.pizza_id = p.pizza_id
JOIN size  s       ON ps.size_id  = s.size_id
JOIN category c    ON p.category_id = c.category_id;

SELECT * FROM full_transactions LIMIT 100;

-- ===== Задача 13. Доход по категориям пицц =====
SELECT c.category_name,
       ROUND(SUM(ps.unit_price * od.quantity), 2) AS revenue
FROM order_details od
JOIN pizza_size ps ON od.pizza_size_id = ps.pizza_size_id
JOIN pizza p       ON ps.pizza_id = p.pizza_id
JOIN category c    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

-- ===== Задача 14. Размер пиццы — лидер продаж в Q3 и Q4 2015 =====
SELECT
  CASE WHEN CAST(strftime('%m', o.order_datetime) AS INTEGER) BETWEEN 7 AND 9
       THEN 'Q3' ELSE 'Q4' END AS quarter,
  s.size_name, SUM(od.quantity) AS total_qty
FROM order_details od
JOIN orders o      ON od.order_id = o.order_id
JOIN pizza_size ps ON od.pizza_size_id = ps.pizza_size_id
JOIN size  s       ON ps.size_id  = s.size_id
WHERE date(o.order_datetime) >= '2015-07-01'
  AND date(o.order_datetime) <  '2016-01-01'
GROUP BY quarter, s.size_name
ORDER BY quarter, total_qty DESC;
