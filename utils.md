Comandos utiles de sql para visualizar en la db

Tamaño DB (GB)

SELECT 
    table_schema AS 'Base de Datos', 
    ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 4) AS 'Tamaño Total (GB)' 
FROM 
    information_schema.TABLES 
WHERE 
    table_schema = DATABASE() -- Usa la DB a la que estás conectado actualmente
GROUP BY 
    table_schema;


Tamaño DB tabla por tabla(MB)

SELECT 
    table_name AS 'Tabla', 
    table_rows AS 'Filas (Aprox)', 
    ROUND(((data_length + index_length) / 1024 / 1024), 4) AS 'Tamaño (MB)' 
FROM 
    information_schema.TABLES 
WHERE 
    table_schema = DATABASE() 
ORDER BY 
    (data_length + index_length) DESC;
