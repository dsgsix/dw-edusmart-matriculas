BEGIN;

CREATE TABLE public.dim_estudiante (
    sk_estudiante SERIAL PRIMARY KEY,
    id_estudiante_nk INT NOT NULL,
    nombre_estudiante VARCHAR(100) NOT NULL,
    provincia_origen VARCHAR(50) NOT NULL
);

CREATE TABLE public.dim_curso (
    sk_curso SERIAL PRIMARY KEY,
    id_curso_nk INT NOT NULL,
    nombre_curso VARCHAR(100) NOT NULL,
    creditos INT NOT NULL
);

CREATE TABLE public.dim_facultad (
    sk_facultad SERIAL PRIMARY KEY,
    id_facultad_nk INT NOT NULL,
    nombre_facultad VARCHAR(100) NOT NULL
);

CREATE TABLE public.dim_tiempo (
    sk_tiempo INT PRIMARY KEY, -- AAAAMMDD, por ejemplo 20261006
    fecha DATE NOT NULL,
    anio INT NOT NULL,
    trimestre INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    dia INT NOT NULL
);

CREATE TABLE public.fact_matricula (
    sk_estudiante INT NOT NULL,
    sk_curso INT NOT NULL,
    sk_facultad INT NOT NULL,
    sk_tiempo INT NOT NULL,
    monto_pagado_usd NUMERIC(10, 2) NOT NULL,
    porcentaje_descuento_beca NUMERIC(5, 2) DEFAULT 0.00,
    cantidad_matriculas INT DEFAULT 1,
    CONSTRAINT pk_fact_matricula
        PRIMARY KEY (sk_estudiante, sk_curso, sk_facultad, sk_tiempo),
    CONSTRAINT fk_fact_estudiante
        FOREIGN KEY (sk_estudiante)
        REFERENCES public.dim_estudiante(sk_estudiante),
    CONSTRAINT fk_fact_curso
        FOREIGN KEY (sk_curso)
        REFERENCES public.dim_curso(sk_curso),
    CONSTRAINT fk_fact_facultad
        FOREIGN KEY (sk_facultad)
        REFERENCES public.dim_facultad(sk_facultad),
    CONSTRAINT fk_fact_tiempo
        FOREIGN KEY (sk_tiempo)
        REFERENCES public.dim_tiempo(sk_tiempo)
);

CREATE INDEX ix_fact_matricula_tiempo
    ON public.fact_matricula(sk_tiempo);
CREATE INDEX ix_fact_matricula_facultad
    ON public.fact_matricula(sk_facultad);

COMMIT;
