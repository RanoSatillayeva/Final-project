Финальный проект
1
Используя данные таблиц customer_info.xlsx (информация о клиентах) и transactions_info.xlsx 
(информация о транзакциях за период с 01.06.2015 по 01.06.2016), нужно вывести:
список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период, 
средний чек за период с 01.06.2015 по 01.06.2016, средняя сумма покупок за месяц, количество всех операций по клиенту за период;
информацию в разрезе месяцев:


2.
средняя сумма чека в месяц;
среднее количество операций в месяц;
среднее количество клиентов, которые совершали операции;
долю от общего количества операций за год и долю в месяц от общей суммы операций;
вывести % соотношение M/F/NA в каждом месяце с их долей затрат;

3.
возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество операций
за весь период, и поквартально - средние показатели и %;


SELECT 
    ID_client,
    COUNT(Id_check) AS total_operations,
    AVG(Sum_payment) AS avg_check,
    SUM(Sum_payment) / 12 AS avg_monthly_payment
FROM transactions
WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12;



WITH monthly_data AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        COUNT(t.Id_check) AS monthly_ops,
        SUM(t.Sum_payment) AS monthly_sum,
        COUNT(DISTINCT t.ID_client) AS monthly_clients
    FROM transactions t
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
    GROUP BY 1
),
gender_data AS (
    SELECT 
        DATE_FORMAT(t.date_new, '%Y-%m') AS month,
        c.Gender,
        COUNT(t.Id_check) AS gender_ops,
        SUM(t.Sum_payment) AS gender_sum
    FROM transactions t
    JOIN customers c ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
    GROUP BY 1, 2
)
SELECT 
    m.month,
    m.monthly_sum / m.monthly_ops AS avg_check_monthly,
    m.monthly_ops / m.monthly_clients AS avg_ops_per_client,
    m.monthly_clients,
    m.monthly_ops / SUM(m.monthly_ops) OVER() AS ops_share_year,
    m.monthly_sum / SUM(m.monthly_sum) OVER() AS sum_share_year,
    
    MAX(CASE WHEN g.Gender = 'M' THEN g.gender_sum / m.monthly_sum END) AS M_sum_share,
    MAX(CASE WHEN g.Gender = 'F' THEN g.gender_sum / m.monthly_sum END) AS F_sum_share
FROM monthly_data m
JOIN gender_data g ON m.month = g.month
GROUP BY m.month;



SELECT 
    CASE 
        WHEN Age IS NULL THEN 'Unknown'
        ELSE CONCAT(FLOOR(Age/10)*10, '-', FLOOR(Age/10)*10 + 9)
    END AS age_group,
    
    SUM(Sum_payment) AS total_sum,
    COUNT(Id_check) AS total_ops,
    
    QUARTER(date_new) AS qr,
    AVG(Sum_payment) AS qr_avg_sum,
    COUNT(Id_check) / COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) AS qr_avg_ops_per_month
FROM transactions t
LEFT JOIN customers c ON t.ID_client = c.Id_client
WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
GROUP BY age_group, qr
ORDER BY age_group, qr;

