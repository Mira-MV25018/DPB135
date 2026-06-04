-- ============================================================
-- PROYECTO FINAL: CINESOFT DB - SISTEMA DE GESTIÓN DE CINE
-- UNIVERSIDAD DE EL SALVADOR - IDS
-- ============================================================

SET SERVEROUTPUT ON;

-- 1. LIMPIEZA (Opcional: Descomenta si deseas borrar todo antes de empezar)
/*
DROP TABLE BOLETOS CASCADE CONSTRAINTS;
DROP TABLE HORARIOS CASCADE CONSTRAINTS;
DROP TABLE SALAS CASCADE CONSTRAINTS;
DROP TABLE PELICULAS CASCADE CONSTRAINTS;
DROP TABLE GENEROS CASCADE CONSTRAINTS;
DROP TABLE CLIENTES CASCADE CONSTRAINTS;
DROP TABLE USUARIOS CASCADE CONSTRAINTS;
DROP TABLE AUDITORIA CASCADE CONSTRAINTS;
DROP TABLE LOG_ERRORES CASCADE CONSTRAINTS;
DROP SEQUENCE seq_generos;
DROP SEQUENCE seq_peliculas;
DROP SEQUENCE seq_salas;
DROP SEQUENCE seq_horarios;
DROP SEQUENCE seq_clientes;
DROP SEQUENCE seq_usuarios;
DROP SEQUENCE seq_boletos;
DROP SEQUENCE seq_auditoria;
DROP SEQUENCE seq_log_errores;
*/

-- 1. SECUENCIAS
CREATE SEQUENCE seq_generos     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_peliculas   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_salas       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_horarios    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_clientes    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_usuarios    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_boletos     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_auditoria   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_log_errores START WITH 1 INCREMENT BY 1;

-- 2. TABLAS (DDL)
CREATE TABLE GENEROS (
    id_genero     NUMBER DEFAULT seq_generos.NEXTVAL PRIMARY KEY,
    nombre_genero VARCHAR2(50) NOT NULL
);

CREATE TABLE PELICULAS (
    id_pelicula   NUMBER DEFAULT seq_peliculas.NEXTVAL PRIMARY KEY,
    titulo        VARCHAR2(150) NOT NULL,
    duracion_min  NUMBER NOT NULL,
    clasificacion VARCHAR2(10) CHECK (clasificacion IN ('G','PG','PG-13','R')),
    id_genero     NUMBER REFERENCES GENEROS(id_genero),
    sinopsis      VARCHAR2(500),
    fecha_estreno DATE,
    estado        VARCHAR2(20) DEFAULT 'EN CARTELERA' CHECK (estado IN ('EN CARTELERA','PROXIMAMENTE','RETIRADA'))
);

CREATE TABLE SALAS (
    id_sala             NUMBER DEFAULT seq_salas.NEXTVAL PRIMARY KEY,
    nombre_sala         VARCHAR2(50) NOT NULL,
    capacidad_asientos  NUMBER NOT NULL,
    tipo_sala           VARCHAR2(20) CHECK (tipo_sala IN ('2D','3D','IMAX','4DX')),
    estado              VARCHAR2(20) DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA','MANTENIMIENTO'))
);

CREATE TABLE HORARIOS (
    id_horario   NUMBER DEFAULT seq_horarios.NEXTVAL PRIMARY KEY,
    id_pelicula  NUMBER NOT NULL REFERENCES PELICULAS(id_pelicula),
    id_sala      NUMBER NOT NULL REFERENCES SALAS(id_sala),
    fecha_hora   DATE NOT NULL,
    precio_base  NUMBER(8,2) NOT NULL,
    estado       VARCHAR2(20) DEFAULT 'PROGRAMADA' CHECK (estado IN ('PROGRAMADA','EN CURSO','FINALIZADA','CANCELADA'))
);

CREATE TABLE CLIENTES (
    id_cliente      NUMBER DEFAULT seq_clientes.NEXTVAL PRIMARY KEY,
    nombre          VARCHAR2(80) NOT NULL,
    apellido        VARCHAR2(80) NOT NULL,
    email           VARCHAR2(100) UNIQUE,
    telefono        VARCHAR2(15),
    fecha_registro  DATE DEFAULT SYSDATE,
    estado          VARCHAR2(20) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE USUARIOS (
    id_usuario    NUMBER DEFAULT seq_usuarios.NEXTVAL PRIMARY KEY,
    username      VARCHAR2(50) UNIQUE NOT NULL,
    password_hash VARCHAR2(200) NOT NULL,
    rol           VARCHAR2(30) CHECK (rol IN ('CAJERO','SUPERVISOR','ADMIN')),
    estado        VARCHAR2(20) DEFAULT 'ACTIVO'
);

CREATE TABLE BOLETOS (
    id_boleto     NUMBER DEFAULT seq_boletos.NEXTVAL PRIMARY KEY,
    id_horario    NUMBER NOT NULL REFERENCES HORARIOS(id_horario),
    id_cliente    NUMBER NOT NULL REFERENCES CLIENTES(id_cliente),
    id_usuario    NUMBER NOT NULL REFERENCES USUARIOS(id_usuario),
    num_asiento   VARCHAR2(10) NOT NULL,
    monto_pagado  NUMBER(8,2) NOT NULL,
    fecha_emision DATE DEFAULT SYSDATE,
    tipo_boleto   VARCHAR2(20) DEFAULT 'GENERAL' CHECK (tipo_boleto IN ('GENERAL','ESTUDIANTE','TERCERA EDAD')),
    CONSTRAINT uq_asiento_horario UNIQUE (id_horario, num_asiento)
);

CREATE TABLE AUDITORIA (
    id_auditoria   NUMBER DEFAULT seq_auditoria.NEXTVAL PRIMARY KEY,
    tabla_afectada VARCHAR2(50),
    accion         VARCHAR2(10),
    usuario_oracle VARCHAR2(50),
    fecha_hora     DATE DEFAULT SYSDATE,
    valor_anterior VARCHAR2(500),
    valor_nuevo    VARCHAR2(500)
);

CREATE TABLE LOG_ERRORES (
    id_log         NUMBER DEFAULT seq_log_errores.NEXTVAL PRIMARY KEY,
    procedimiento  VARCHAR2(100),
    mensaje_error  VARCHAR2(500),
    fecha_hora     DATE DEFAULT SYSDATE,
    usuario_oracle VARCHAR2(50)
);

-- 3. DATOS DE PRUEBA (DML)
INSERT INTO GENEROS (nombre_genero) VALUES ('Acción');
INSERT INTO GENEROS (nombre_genero) VALUES ('Terror');
INSERT INTO PELICULAS (titulo, duracion_min, clasificacion, id_genero, estado) VALUES ('Guardianes', 120, 'PG-13', 1, 'EN CARTELERA');
INSERT INTO SALAS (nombre_sala, capacidad_asientos, tipo_sala) VALUES ('Sala IMAX', 100, 'IMAX');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base) VALUES (1, 1, SYSDATE+1, 10.00);
INSERT INTO CLIENTES (nombre, apellido, email) VALUES ('Juan', 'Perez', 'juan@mail.com');
INSERT INTO USUARIOS (username, password_hash, rol) VALUES ('cajero1', '123', 'CAJERO');
COMMIT;

-- 4. VISTAS
CREATE OR REPLACE VIEW vw_cartelera_hoy AS
SELECT H.id_horario, P.titulo AS pelicula, S.nombre_sala, TO_CHAR(H.fecha_hora, 'HH24:MI') AS hora
FROM HORARIOS H
INNER JOIN PELICULAS P ON H.id_pelicula = P.id_pelicula
INNER JOIN SALAS S ON H.id_sala = S.id_sala
WHERE TRUNC(H.fecha_hora) = TRUNC(SYSDATE);

-- 5. PL/SQL: PROCEDIMIENTOS
CREATE OR REPLACE PROCEDURE sp_resumen_periodo(p_inicio DATE, p_fin DATE) AS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM BOLETOS WHERE fecha_emision BETWEEN p_inicio AND p_fin;
    DBMS_OUTPUT.PUT_LINE('Total boletos en periodo: ' || v_total);
EXCEPTION
    WHEN OTHERS THEN ROLLBACK; RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_top_elementos(p_n NUMBER) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Listando Top ' || p_n);
END;
/

-- 6. SEGURIDAD
-- Nota: Requiere permisos de SYSTEM para crear usuarios
/*
CREATE USER usr_lectura IDENTIFIED BY "Lectura2026#";
GRANT CREATE SESSION TO usr_lectura;
GRANT SELECT ON PELICULAS TO usr_lectura;
*/

PROMPT Script CineSoft DB cargado con éxito.
