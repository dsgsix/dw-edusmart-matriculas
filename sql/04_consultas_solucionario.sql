-- Consultas del solucionario. Solo lectura; pueden repetirse.
-- En pgAdmin seleccionar cada SELECT completo y ejecutar por separado.

-- Ejercicio 1.1: desglose por estudiante, provincia y facultad.
SELECT
    e.nombre_estudiante,
    e.provincia_origen,
    f.nombre_facultad,
    m.monto_pagado_usd
FROM public.fact_matricula m
JOIN public.dim_estudiante e ON m.sk_estudiante = e.sk_estudiante
JOIN public.dim_facultad f ON m.sk_facultad = f.sk_facultad;

-- Ejercicio 1.2: curso, creditos y monto de cada inscripcion.
SELECT
    c.nombre_curso,
    c.creditos,
    m.monto_pagado_usd
FROM public.fact_matricula m
JOIN public.dim_curso c ON m.sk_curso = c.sk_curso;

-- Ejercicio 2.1: recaudacion e inscripciones por facultad.
SELECT
    f.nombre_facultad,
    SUM(m.monto_pagado_usd) AS recaudacion_total_usd,
    SUM(m.cantidad_matriculas) AS total_inscripciones
FROM public.fact_matricula m
JOIN public.dim_facultad f ON m.sk_facultad = f.sk_facultad
GROUP BY f.nombre_facultad
ORDER BY recaudacion_total_usd DESC;

-- Ejercicio 2.2: cursos con promedio de descuento >= 5%.
-- AVG responde al promedio simple por inscripcion solicitado.
SELECT
    c.nombre_curso,
    AVG(m.porcentaje_descuento_beca) AS promedio_descuento_pct
FROM public.fact_matricula m
JOIN public.dim_curso c ON m.sk_curso = c.sk_curso
GROUP BY c.nombre_curso
HAVING AVG(m.porcentaje_descuento_beca) >= 5.00;
