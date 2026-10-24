BEGIN;

WITH nuevo_tiempo AS (
    INSERT INTO public.dim_tiempo
        (sk_tiempo, fecha, anio, trimestre, mes, nombre_mes, dia)
    VALUES (20261006, DATE '2026-10-06', 2026, 4, 10, 'Octubre', 6)
    RETURNING sk_tiempo
), nueva_facultad AS (
    INSERT INTO public.dim_facultad (id_facultad_nk, nombre_facultad)
    VALUES (101, 'Facultad de Ingeniería y Ciencias Aplicadas')
    RETURNING sk_facultad
), nuevo_estudiante AS (
    INSERT INTO public.dim_estudiante
        (id_estudiante_nk, nombre_estudiante, provincia_origen)
    VALUES (9001, 'Carlos Pérez', 'Pichincha')
    RETURNING sk_estudiante
), nuevo_curso AS (
    INSERT INTO public.dim_curso (id_curso_nk, nombre_curso, creditos)
    VALUES (505, 'Inteligencia de Negocios', 4)
    RETURNING sk_curso
)
INSERT INTO public.fact_matricula (
    sk_estudiante, sk_curso, sk_facultad, sk_tiempo,
    monto_pagado_usd, porcentaje_descuento_beca, cantidad_matriculas
)
SELECT e.sk_estudiante, c.sk_curso, f.sk_facultad, t.sk_tiempo,
       350.00, 10.00, 1
FROM nuevo_estudiante e
CROSS JOIN nuevo_curso c
CROSS JOIN nueva_facultad f
CROSS JOIN nuevo_tiempo t;

COMMIT;
