# Guía de ejecución de EduSmart en PostgreSQL y publicación con Git

Esta práctica implementa el modelo de **matriculación y pagos** de la guía, carga su registro de ejemplo y ejecuta las cuatro consultas del solucionario. Sigue los pasos en orden. Usa pgAdmin para SQL y PowerShell para Git.

## 1 Qué material se utiliza

- La guía práctica define las dimensiones estudiante, curso, facultad y tiempo, y la tabla `fact_matricula`.
- El solucionario aporta los ejercicios SQL 1.1, 1.2, 2.1 y 2.2.
- El PDF Actividad 3 sirve de referencia para la organización y las evidencias del informe. Su modelo de rendimiento académico es diferente: no debes copiar `dim_asignatura`, `fact_rendimiento_academico` ni sus conteos.

El PDF es un informe de ejemplo, no una rúbrica que establezca una extensión obligatoria de 15 páginas. Usa tus datos de portada, capturas, fecha real, enlace y commit. El código se ha separado en archivos ejecutables; no hace falta volver a escribirlo desde los documentos Word.

Los cinco archivos SQL se comprobaron en una instancia temporal de PostgreSQL 18 el 23 de octubre de 2026. Se verificaron la estructura, los resultados de la carga y las consultas, el rechazo de referencias inexistentes y hechos duplicados, y la carga con SK generadas distintas de 1. Esa comprobación técnica no sustituye las capturas de tu propia ejecución para el informe.

## 2 Archivos de trabajo

```text
Ciencia de Datos/
  README.md
  .gitignore
  sql/
    00_crear_base.sql
    01_esquema_estrella.sql
    02_carga_datos.sql
    03_verificaciones.sql
    04_consultas_solucionario.sql
  docs/
    guia_informe.md
    evidencias/
      README.md
```

Conserva esta única carpeta durante todo el procedimiento. Los archivos ya están guardados en `C:\Users\usuario\Documents\ChatGPT\Ciencia de Datos`. Si mueves el proyecto, adapta la ruta en PowerShell.

## 3 Revisar las herramientas

En PowerShell:

```powershell
Set-Location -LiteralPath 'C:\Users\usuario\Documents\ChatGPT\Ciencia de Datos'
Get-Location
Get-ChildItem .\sql
psql --version
git --version
git config --get user.name
git config --get user.email
```

Se detectó PostgreSQL 18 en este equipo. No necesitas instalar PostgreSQL 15 para seguir la guía: su requisito es 15 o superior. Si `psql` no se reconoce, puedes usar `& 'C:\Program Files\PostgreSQL\18\bin\psql.exe'` en lugar de `psql`, o trabajar exclusivamente desde pgAdmin.

Si Git muestra tu nombre y correo correctos, continúa. Si no están configurados, ejecuta estos comandos con tus datos; la configuración local afecta solo a este repositorio:

```powershell
git config user.name 'TU NOMBRE'
git config user.email 'TU CORREO DE GIT'
```

Tener una cuenta de GitHub y configurar el autor de los commits son pasos diferentes de la autenticación para subirlos. Más adelante `git push` puede abrir el navegador para iniciar sesión.

## 4 Resolver el ejercicio conceptual de Kimball

Desarrolla estas decisiones en el informe:

1. **Proceso:** registro y pago de matriculación académica.
2. **Grano declarado:** una inscripción de un estudiante en un curso durante un periodo lectivo.
3. **Dimensiones:** estudiante, curso, facultad y tiempo.
4. **Hechos:** monto pagado en USD, porcentaje de descuento por beca y cantidad de matrículas.

`monto_pagado_usd` y `cantidad_matriculas` son aditivos bajo el grano del ejemplo. El porcentaje es **no aditivo**: sumar porcentajes no proporciona una medida útil. El ejercicio 2.2 solicita `AVG`, que calcula el promedio simple por inscripción. Para un descuento global ponderado por dinero se necesitarían los importes base o los pesos pertinentes; esa medida no equivale al promedio simple solicitado.

**Límite del DDL de la guía:** el periodo lectivo no figura explícitamente en las tablas. La PK del hecho identifica la combinación estudiante, curso, facultad y fecha. Mantén ese DDL para reproducir la actividad y explica la diferencia en las conclusiones; no afirmes que ya implementa una restricción por periodo. Tampoco implementa historial SCD ni unicidad de las NK.

## 5 Crear la base desde pgAdmin

1. Abre pgAdmin 4 y conecta al servidor PostgreSQL local. Usa el puerto y las credenciales de tu instalación; normalmente `localhost`, `5432` y el usuario `postgres`.
2. En el árbol abre **Servers > tu servidor > Databases > postgres**.
3. Haz clic derecho sobre `postgres` y abre **Query Tool**.
4. Comprueba que Auto commit esté activado. Abre `sql/00_crear_base.sql` con el botón de abrir archivo y ejecuta su sentencia con **Execute script**. También puedes pegar:

```sql
CREATE DATABASE db_edusmart_uti;
```

5. Guarda una captura con `CREATE DATABASE` y el mensaje de éxito.
6. Actualiza **Databases** con **Refresh**. Haz clic derecho sobre **db_edusmart_uti > Query Tool**. Esta nueva conexión es la que usarás desde ahora.
7. Ejecuta:

```sql
SELECT current_database();
```

El resultado debe ser `db_edusmart_uti`. Crear una base no cambia automáticamente la conexión de una pestaña ya abierta. No pegues `\c` en Query Tool: ese comando pertenece a psql.

Si la base ya existe y contiene trabajo anterior, revisa su contenido antes de continuar. No ejecutes una instrucción de borrado para resolver el aviso. Elige otra base vacía si necesitas repetir toda la práctica y adapta su nombre en las conexiones.

## 6 Ejecutar el DDL

1. En Query Tool conectado a `db_edusmart_uti`, abre `sql/01_esquema_estrella.sql`.
2. Ejecuta el archivo completo, incluidos `BEGIN` y `COMMIT`. Si hay texto seleccionado, se ejecutará esa selección: quítala o selecciona todo.
3. Revisa **Messages** y guarda una captura del SQL y la confirmación de ejecución correcta.
4. En el árbol actualiza **Schemas > public > Tables**. Debes ver:

```text
dim_estudiante
dim_curso
dim_facultad
dim_tiempo
fact_matricula
```

Los nombres aparecen en minúsculas porque no se han entrecomillado. Las tres primeras dimensiones usan `SERIAL` para sus SK. La dimensión tiempo usa una clave entera `AAAAMMDD`, con significado de calendario.

Este archivo conserva columnas, PK, FK e índices de la guía; añade una transacción y hace explícito el esquema `public`. No debe ejecutarse varias veces en la misma base: sus `CREATE TABLE` requieren que las tablas no existan. Si una ejecución falla dentro de la transacción, ejecuta `ROLLBACK;`, revisa el primer error y corrígelo antes de continuar.

## 7 Cargar los datos de ejemplo

1. Abre `sql/02_carga_datos.sql` en esa misma base.
2. Ejecuta el archivo completo una sola vez.
3. Revisa que no haya errores y guarda la evidencia.

Se carga una fila en cada dimensión y una matrícula: Carlos Pérez, Pichincha, Inteligencia de Negocios, 4 créditos, Facultad de Ingeniería y Ciencias Aplicadas, fecha 6 de octubre de 2026, pago de USD 350.00 y descuento del 10%.

La carga usa `RETURNING` para obtener las claves recién generadas y enlazar el hecho con ellas. Esto evita asumir que las secuencias siempre producen el valor 1. No se calcula otro pago a partir del descuento: 350.00 ya es el importe indicado por el material.

No repitas la carga: `dim_tiempo` rechazará la fecha duplicada. Si falla, ejecuta `ROLLBACK;` antes de corregirla. Las secuencias pueden dejar huecos tras intentos fallidos; eso no rompe la relación entre NK y SK.

## 8 Verificar la estructura y la carga

Abre `sql/03_verificaciones.sql`. Selecciona y ejecuta **cada bloque SELECT completo por separado**, incluyendo su punto y coma. Así podrás capturar cada resultado de forma legible.

| Bloque | Qué comprueba | Resultado esperado en una base nueva |
| --- | --- | --- |
| V1 | Base actual | db_edusmart_uti |
| V2 | Tablas | 5 filas |
| V3 | SK automáticas | 3 filas integer con `nextval(...)` |
| V4 | FK del hecho | 4 filas |
| V5 | PK del hecho | 1 fila con las cuatro SK |
| V6 | Índices del hecho | 3 filas: 2 explícitos y 1 creado por la PK |
| V7 | Conteos tras carga inicial | 1 fila de datos en cada tabla |
| V8 | JOIN de las cuatro dimensiones | Carlos Pérez y pago de 350.00 |

La PK crea automáticamente un índice adicional. Por eso este modelo tiene **dos índices explícitos y tres índices totales en la tabla de hechos**. No copies los conteos del PDF, que corresponden a otro esquema. Verificar un índice no demuestra una mejora de rendimiento.

## 9 Ejecutar las cuatro consultas del solucionario

Abre `sql/04_consultas_solucionario.sql` y ejecuta cada SELECT por separado. Guarda una captura de cada consulta junto a **Data Output**.

| Ejercicio | Operación | Resultado esperado con el único registro |
| --- | --- | --- |
| 1.1 | JOIN estudiante y facultad | Carlos Pérez, Pichincha, facultad y 350.00 |
| 1.2 | JOIN curso | Inteligencia de Negocios, 4 créditos y 350.00 |
| 2.1 | SUM por facultad | Recaudación 350.00 y 1 inscripción |
| 2.2 | AVG y HAVING >= 5 | Inteligencia de Negocios y promedio 10% |

PostgreSQL puede mostrar muchos decimales para AVG; `10.000000...` representa el mismo 10%. Los cuatro resultados tienen una fila porque el material carga una sola matrícula. Esta carga valida el recorrido básico; no representa una población universitaria ni una prueba de rendimiento.

## 10 Alternativa por PowerShell con psql

Usa este camino **en lugar de repetir la creación y la carga hechas en pgAdmin**. Los archivos 03 y 04 sí se pueden repetir. No ejecutes dos veces los archivos 00, 01 y 02 sobre los mismos objetos.

Desde la carpeta del proyecto, en una instalación local con usuario `postgres` y puerto `5432`:

```powershell
$env:PGCLIENTENCODING = 'UTF8'
psql -X -h localhost -p 5432 -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\sql\00_crear_base.sql
```

Si termina correctamente, ejecuta **uno a uno**, deteniéndote ante el primer error:

```powershell
psql -X -h localhost -p 5432 -U postgres -d db_edusmart_uti -v ON_ERROR_STOP=1 -f .\sql\01_esquema_estrella.sql
psql -X -h localhost -p 5432 -U postgres -d db_edusmart_uti -v ON_ERROR_STOP=1 -f .\sql\02_carga_datos.sql
psql -X -h localhost -p 5432 -U postgres -d db_edusmart_uti -v ON_ERROR_STOP=1 -f .\sql\03_verificaciones.sql
psql -X -h localhost -p 5432 -U postgres -d db_edusmart_uti -v ON_ERROR_STOP=1 -f .\sql\04_consultas_solucionario.sql
```

`ON_ERROR_STOP=1` hace que psql se detenga ante un error dentro de cada archivo. Introduce la contraseña cuando la solicite; no la guardes en los scripts. `-X` evita que una configuración personal de psql cambie el comportamiento de los ejemplos.

## 11 Publicar con Git y GitHub

Los siguientes pasos los ejecutas tú después de revisar los archivos y producir tus evidencias. En GitHub crea un repositorio llamado, por ejemplo, **dw-edusmart-matriculas**. Elige visibilidad pública o comparte acceso con el docente. Créalo vacío, sin README, licencia ni `.gitignore` automáticos, porque ya tienes archivos locales.

Abre PowerShell y confirma la carpeta:

```powershell
Set-Location -LiteralPath 'C:\Users\usuario\Documents\ChatGPT\Ciencia de Datos'
Get-Location
Get-ChildItem .\sql
git status
git remote -v
```

Esta carpeta ya tiene un repositorio Git inicializado. Si copias los archivos a otra carpeta que aún no tiene Git, primero ejecuta `git init` allí. Trabaja siempre desde la raíz que contiene `sql` y `docs`.

Revisa los archivos que vas a incluir y crea el primer commit:

```powershell
git add .gitignore README.md sql docs
git diff --cached --stat
git diff --cached
git commit -m 'feat: implementar esquema y consultas de matriculas EduSmart'
git branch -M main
```

Después reemplaza `TU_USUARIO` por tu usuario real y usa el nombre del repositorio que acabas de crear:

```powershell
git remote add origin https://github.com/TU_USUARIO/dw-edusmart-matriculas.git
git remote -v
git push -u origin main
```

Si `origin` ya existe, revisa su URL. Si es el repositorio correcto, omite `remote add`. Si es incorrecto y corresponde cambiarlo, usa:

```powershell
git remote set-url origin https://github.com/TU_USUARIO/dw-edusmart-matriculas.git
```

Si se abre un navegador para autenticarte, completa el inicio de sesión. Si Git solicita una contraseña para HTTPS, GitHub utiliza un token de acceso personal en ese campo, o un gestor de credenciales; no la contraseña habitual de tu cuenta. No pegues tokens en el informe ni en el código.

Comprueba la publicación:

```powershell
git status
git log -1 --oneline
```

Abre tu repositorio en GitHub y revisa `README.md` y los cinco archivos `sql/`. Guarda capturas del push exitoso, del commit y de un SQL visible en GitHub. Subir scripts permite recrear el esquema; Git no copia por sí solo el servidor PostgreSQL ni sus datos de ejecución.

## 12 Preparar el informe y entregar

Sigue `docs/guia_informe.md`. Guarda las capturas propias en `docs/evidencias/`. Completa el informe con los resultados que realmente obtuviste y expórtalo a PDF, por ejemplo `docs/Informe_EduSmart.pdf`.

Después de terminarlo, súbelo con un nuevo commit:

```powershell
git add docs
git diff --cached --stat
git commit -m 'docs: agregar informe y evidencias de EduSmart'
git push
```

En Canvas entrega el enlace a tu repositorio y la evidencia del JOIN que pide la guía. Adjunta también el informe cuando la tarea lo solicite. Verifica que el docente pueda abrir el enlace.

## Problemas frecuentes

| Mensaje o situación | Qué revisar |
| --- | --- |
| `connection refused` | Servicio PostgreSQL iniciado, host y puerto de la instalación. |
| `password authentication failed` | Usuario y contraseña de PostgreSQL; no son los de GitHub. |
| `relation already exists` | Ya ejecutaste el DDL en esa base. Verifica V2; no lo repitas. |
| `current transaction is aborted` | Ejecuta `ROLLBACK;`, revisa el primer error y corrígelo. |
| `duplicate key value` al cargar | La carga ya se realizó o existe esa fecha. Revisa V7 y V8. |
| `relation does not exist` | Base equivocada, DDL pendiente o transacción que falló. |
| `nothing to commit` | Comprueba carpeta, `Get-ChildItem .\sql`, `git status` y si los archivos ya están en un commit. |
| `remote origin already exists` | Usa `git remote -v` y revisa la URL; no repitas `remote add`. |
| `src refspec main does not match any` | Asegúrate de haber creado un commit y de tener la rama main. |
| Push rechazado por historia remota | Puede que el remoto se haya creado con archivos. Usa `git fetch origin` y revisa la historia antes de integrar; evita forzar el push. |

## Referencias técnicas

- [pgAdmin Query Tool](https://www.pgadmin.org/docs/pgadmin4/latest/query_tool.html): apertura, ejecución y revisión de consultas.
- [PostgreSQL 18 psql](https://www.postgresql.org/docs/18/app-psql.html): archivos SQL y opciones de ejecución.
- [PostgreSQL pg_constraint](https://www.postgresql.org/docs/18/catalog-pg-constraint.html): verificación de PK y FK.
- [PostgreSQL pg_indexes](https://www.postgresql.org/docs/18/view-pg-indexes.html): definición de índices.
- [GitHub publicación de código local](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github): creación de un remoto vacío y primer push.
- [GitHub repositorios remotos y autenticación](https://docs.github.com/en/get-started/git-basics/about-remote-repositories): HTTPS y credenciales.
- [Kimball Group clasificación de hechos](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/additive-semi-additive-non-additive-fact/): medidas aditivas, semi-aditivas y no aditivas.
