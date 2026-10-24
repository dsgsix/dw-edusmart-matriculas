-- V1. Conexion y version.
SELECT current_database() AS base_actual, version() AS version_postgresql;

-- V2. Tablas del esquema dimensional.
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
  AND table_name IN (
      'dim_estudiante', 'dim_curso', 'dim_facultad',
      'dim_tiempo', 'fact_matricula'
  )
ORDER BY table_name;

-- V3. Claves sustitutas.
SELECT table_name, column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (table_name, column_name) IN (
      ('dim_estudiante', 'sk_estudiante'),
      ('dim_curso', 'sk_curso'),
      ('dim_facultad', 'sk_facultad')
  )
ORDER BY table_name;

-- V4. Claves foraneas.
SELECT conname AS restriccion,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE conrelid = 'public.fact_matricula'::regclass
  AND contype = 'f'
ORDER BY conname;

-- V5. Clave primaria compuesta.
SELECT conname AS restriccion,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint
WHERE conrelid = 'public.fact_matricula'::regclass
  AND contype = 'p';

-- V6. Indices de la tabla de hechos.
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'fact_matricula'
ORDER BY indexname;

-- V7. Conteo de registros.
SELECT 'dim_estudiante' AS tabla, COUNT(*) AS filas FROM public.dim_estudiante
UNION ALL
SELECT 'dim_curso', COUNT(*) FROM public.dim_curso
UNION ALL
SELECT 'dim_facultad', COUNT(*) FROM public.dim_facultad
UNION ALL
SELECT 'dim_tiempo', COUNT(*) FROM public.dim_tiempo
UNION ALL
SELECT 'fact_matricula', COUNT(*) FROM public.fact_matricula
ORDER BY tabla;

-- V8. Consulta integrada de matriculas.
SELECT e.nombre_estudiante,
       f.nombre_facultad,
       c.nombre_curso,
       t.fecha,
       m.monto_pagado_usd
FROM public.fact_matricula m
JOIN public.dim_estudiante e ON m.sk_estudiante = e.sk_estudiante
JOIN public.dim_facultad f ON m.sk_facultad = f.sk_facultad
JOIN public.dim_curso c ON m.sk_curso = c.sk_curso
JOIN public.dim_tiempo t ON m.sk_tiempo = t.sk_tiempo;
