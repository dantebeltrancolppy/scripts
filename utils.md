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


Guía: Generación de Credenciales Temporales AWS CLI

Para ejecutar los scripts de descarga de configuración localmente, necesitas un par de claves de acceso (Access Key y Secret Key) con permisos de lectura sobre S3.

Dado que tu usuario utiliza AWS SSO, no puedes usar credenciales permanentes directamente. Sigue estos pasos para crear un usuario de servicio temporal.

Prerrequisitos

Tener acceso a la consola de AWS con permisos de Administrador o IAMFullAccess.

Tener acceso a AWS CloudShell (recomendado) o AWS CLI configurado con tu usuario SSO.

Pasos para generar claves

Ejecuta los siguientes comandos en tu terminal (CloudShell o local):

1. Crear un usuario temporal

Este usuario será utilizado exclusivamente por tu script local.

aws iam create-user --user-name dante-cli-local


2. Asignar permisos de lectura

Otorgamos permiso de lectura únicamente a S3 (AmazonS3ReadOnlyAccess) para minimizar riesgos.

aws iam attach-user-policy \
    --user-name dante-cli-local \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess


3. Generar Access Keys

Este comando devolverá el JSON con las credenciales.

aws iam create-access-key --user-name dante-cli-local


Salida esperada:

{
    "AccessKey": {
        "UserName": "dante-cli-local",
        "AccessKeyId": "AKIA................",
        "SecretAccessKey": "........................................",
        ...
    }
}


4. Configurar tu entorno local

Copia el archivo .env.example a .env en el mismo directorio donde está el script.

Pega los valores obtenidos en el paso anterior dentro del archivo .env.

Limpieza (Importante)

Cuando termines tu sesión de trabajo, borra el usuario temporal para mantener la seguridad de la cuenta.

# 1. Borrar la access key (necesitas el ID, o bórrala desde la consola web)
aws iam delete-access-key --user-name dante-cli-local --access-key-id AKIA...

# 2. Desvincular políticas
aws iam detach-user-policy --user-name dante-cli-local --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# 3. Borrar el usuario
aws iam delete-user --user-name dante-cli-local
