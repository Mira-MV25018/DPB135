-- ============================================================
-- PROYECTO FINAL: CINESOFT DB - SISTEMA DE GESTIÓN DE CINE
-- UNIVERSIDAD DE EL SALVADOR - IDS
-- CICLO lll-2026
-- INTEGRANTES: 
-- ============================================================

SET SERVEROUTPUT ON;

-- ============================================================
-- 1. LIMPIEZA (DROP)
-- ============================================================

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

-- ============================================================
-- 2. SECUENCIAS (CREATE SEQUENCE)
-- ============================================================

CREATE SEQUENCE seq_generos     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_peliculas   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_salas       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_horarios    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_clientes    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_usuarios    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_boletos     START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_auditoria   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_log_errores START WITH 1 INCREMENT BY 1;

-- ============================================================
-- 3. TABLAS (CREATE TABLE)
-- ============================================================

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

-- ============================================================
-- 4. DATOS DE PRUEBA (INSERT) - 16 CLIENTES
-- ============================================================

INSERT INTO GENEROS (nombre_genero) VALUES ('Acción');
INSERT INTO GENEROS (nombre_genero) VALUES ('Terror');
INSERT INTO GENEROS (nombre_genero) VALUES ('Comedia');
INSERT INTO GENEROS (nombre_genero) VALUES ('Drama');
INSERT INTO GENEROS (nombre_genero) VALUES ('Ciencia Ficción');

INSERT INTO PELICULAS (titulo, duracion_min, clasificacion, id_genero, estado) VALUES ('Guardianes', 120, 'PG-13', 1, 'EN CARTELERA');
INSERT INTO PELICULAS (titulo, duracion_min, clasificacion, id_genero, estado) VALUES ('El Conjuro', 112, 'R', 2, 'EN CARTELERA');
INSERT INTO PELICULAS (titulo, duracion_min, clasificacion, id_genero, estado) VALUES ('Interestelar', 169, 'PG-13', 5, 'EN CARTELERA');
INSERT INTO PELICULAS (titulo, duracion_min, clasificacion, id_genero, estado) VALUES ('Barbie', 114, 'PG-13', 3, 'EN CARTELERA');
INSERT INTO PELICULAS (titulo, duracion_min, clasificacion, id_genero, estado) VALUES ('Oppenheimer', 180, 'R', 4, 'EN CARTELERA');

INSERT INTO SALAS (nombre_sala, capacidad_asientos, tipo_sala, estado) VALUES ('Sala IMAX', 100, 'IMAX', 'ACTIVA');
INSERT INTO SALAS (nombre_sala, capacidad_asientos, tipo_sala, estado) VALUES ('Sala 2D Nro 1', 80, '2D', 'ACTIVA');
INSERT INTO SALAS (nombre_sala, capacidad_asientos, tipo_sala, estado) VALUES ('Sala 3D', 60, '3D', 'ACTIVA');
INSERT INTO SALAS (nombre_sala, capacidad_asientos, tipo_sala, estado) VALUES ('Sala 4DX', 50, '4DX', 'MANTENIMIENTO');
INSERT INTO SALAS (nombre_sala, capacidad_asientos, tipo_sala, estado) VALUES ('Sala Platinum', 40, '2D', 'ACTIVA');

INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (1, 1, SYSDATE+1, 12.00, 'PROGRAMADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (2, 2, SYSDATE+1, 8.00, 'PROGRAMADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (3, 1, SYSDATE+1, 14.00, 'PROGRAMADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (4, 3, SYSDATE+1, 10.00, 'PROGRAMADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (5, 5, SYSDATE+1, 15.00, 'PROGRAMADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (1, 1, SYSDATE-10, 12.00, 'FINALIZADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (2, 2, SYSDATE-15, 8.00, 'FINALIZADA');
INSERT INTO HORARIOS (id_pelicula, id_sala, fecha_hora, precio_base, estado) VALUES (3, 1, SYSDATE-20, 14.00, 'FINALIZADA');

INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Juan', 'Perez', 'juan@mail.com', '7777-1111', SYSDATE-30, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Maria', 'Lopez', 'maria@mail.com', '7777-2222', SYSDATE-60, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Carlos', 'Ramirez', 'carlos@mail.com', '7777-3333', SYSDATE-90, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Ana', 'Gomez', 'ana@mail.com', '7777-4444', SYSDATE-400, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Pedro', 'Fernandez', 'pedro@mail.com', '7777-5555', SYSDATE-15, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Laura', 'Martinez', 'laura@mail.com', '7777-6666', SYSDATE-200, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Jose', 'Sanchez', 'jose@mail.com', '7777-7777', SYSDATE-5, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Carmen', 'Torres', 'carmen@mail.com', '7777-8888', SYSDATE-180, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Miguel', 'Flores', 'miguel@mail.com', '7777-9999', SYSDATE-50, 'INACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Elena', 'Rojas', 'elena@mail.com', '7777-1010', SYSDATE-120, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Pablo', 'Diaz', 'pablo@mail.com', '7777-1112', SYSDATE-10, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Sofia', 'Castro', 'sofia@mail.com', '7777-1113', SYSDATE-300, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Andres', 'Mendoza', 'andres@mail.com', '7777-1114', SYSDATE-2, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Isabel', 'Ortiz', 'isabel@mail.com', '7777-1115', SYSDATE-250, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Ricardo', 'Silva', 'ricardo@mail.com', '7777-1116', SYSDATE-40, 'ACTIVO');
INSERT INTO CLIENTES (nombre, apellido, email, telefono, fecha_registro, estado) VALUES ('Patricia', 'Vega', 'patricia@mail.com', '7777-1117', SYSDATE-700, 'ACTIVO');

INSERT INTO USUARIOS (username, password_hash, rol, estado) VALUES ('cajero1', '123', 'CAJERO', 'ACTIVO');
INSERT INTO USUARIOS (username, password_hash, rol, estado) VALUES ('cajero2', '456', 'CAJERO', 'ACTIVO');
INSERT INTO USUARIOS (username, password_hash, rol, estado) VALUES ('supervisor1', '789', 'SUPERVISOR', 'ACTIVO');
INSERT INTO USUARIOS (username, password_hash, rol, estado) VALUES ('admin1', '000', 'ADMIN', 'ACTIVO');

INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (1, 1, 1, 'A1', 12.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (1, 2, 1, 'A2', 12.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (1, 3, 1, 'A3', 8.40, 'ESTUDIANTE', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (2, 4, 2, 'B1', 8.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (3, 5, 1, 'C1', 14.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (3, 6, 1, 'C2', 14.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (4, 7, 2, 'D1', 10.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (5, 8, 3, 'E1', 15.00, 'TERCERA EDAD', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (6, 9, 1, 'F1', 12.00, 'GENERAL', SYSDATE-10);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (6, 10, 1, 'F2', 12.00, 'GENERAL', SYSDATE-10);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (7, 11, 2, 'G1', 8.00, 'GENERAL', SYSDATE-15);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (7, 12, 2, 'G2', 5.60, 'ESTUDIANTE', SYSDATE-15);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (8, 13, 3, 'H1', 14.00, 'GENERAL', SYSDATE-20);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (8, 14, 3, 'H2', 9.80, 'ESTUDIANTE', SYSDATE-20);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (1, 15, 1, 'A5', 12.00, 'GENERAL', SYSDATE);
INSERT INTO BOLETOS (id_horario, id_cliente, id_usuario, num_asiento, monto_pagado, tipo_boleto, fecha_emision) VALUES (1, 16, 1, 'A6', 12.00, 'GENERAL', SYSDATE);

COMMIT;

-- ============================================================
-- 5. VISTAS (CREATE VIEW)
-- ============================================================

CREATE OR REPLACE VIEW vw_cartelera_hoy AS
SELECT H.id_horario, P.titulo AS pelicula, S.nombre_sala, TO_CHAR(H.fecha_hora, 'HH24:MI') AS hora
FROM HORARIOS H
INNER JOIN PELICULAS P ON H.id_pelicula = P.id_pelicula
INNER JOIN SALAS S ON H.id_sala = S.id_sala
WHERE TRUNC(H.fecha_hora) = TRUNC(SYSDATE);

CREATE OR REPLACE VIEW vw_reporte_taquilla AS
SELECT P.titulo AS pelicula,
       G.nombre_genero AS genero,
       COUNT(DISTINCT H.id_horario) AS total_funciones,
       COUNT(B.id_boleto) AS total_boletos,
       TO_CHAR(SUM(B.monto_pagado), 'FM$999,999.00') AS ingresos_totales
FROM PELICULAS P
INNER JOIN GENEROS G ON P.id_genero = G.id_genero
INNER JOIN HORARIOS H ON P.id_pelicula = H.id_pelicula
INNER JOIN BOLETOS B ON H.id_horario = B.id_horario
GROUP BY P.titulo, G.nombre_genero;

-- ============================================================
-- 6. PROCEDIMIENTOS (P1, P2, P3, P4)
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_resumen_periodo(p_inicio DATE, p_fin DATE) AS
    v_total NUMBER;
    v_monto NUMBER;
    v_promedio NUMBER;
BEGIN
    SELECT COUNT(*), NVL(SUM(monto_pagado),0), NVL(AVG(monto_pagado),0)
    INTO v_total, v_monto, v_promedio
    FROM BOLETOS WHERE fecha_emision BETWEEN p_inicio AND p_fin;
    
    DBMS_OUTPUT.PUT_LINE('=== RESUMEN DEL PERÍODO ===');
    DBMS_OUTPUT.PUT_LINE('Período: ' || TO_CHAR(p_inicio,'DD/MM/YYYY') || ' al ' || TO_CHAR(p_fin,'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Total boletos: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Monto total: $' || ROUND(v_monto,2));
    DBMS_OUTPUT.PUT_LINE('Promedio: $' || ROUND(v_promedio,2));
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO LOG_ERRORES(procedimiento, mensaje_error, usuario_oracle)
        VALUES('sp_resumen_periodo', SQLERRM, USER);
        COMMIT;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_top_elementos(p_n NUMBER) AS
    CURSOR cur_top IS
        SELECT P.titulo, COUNT(B.id_boleto) AS total_boletos, SUM(B.monto_pagado) AS ingresos
        FROM BOLETOS B
        INNER JOIN HORARIOS H ON B.id_horario = H.id_horario
        INNER JOIN PELICULAS P ON H.id_pelicula = P.id_pelicula
        GROUP BY P.titulo
        ORDER BY SUM(B.monto_pagado) DESC
        FETCH FIRST p_n ROWS ONLY;
    v_rank NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TOP ' || p_n || ' PELÍCULAS MÁS TAQUILLERAS ===');
    FOR rec IN cur_top LOOP
        DBMS_OUTPUT.PUT_LINE(v_rank || '. ' || rec.titulo || ' | Boletos: ' || rec.total_boletos || ' | $' || ROUND(rec.ingresos,2));
        v_rank := v_rank + 1;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO LOG_ERRORES(procedimiento, mensaje_error, usuario_oracle)
        VALUES('sp_top_elementos', SQLERRM, USER);
        COMMIT;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_indicadores_categoria AS
    v_variacion NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INDICADORES POR GÉNERO ===');
    FOR rec IN (
        SELECT G.nombre_genero,
               SUM(CASE WHEN EXTRACT(MONTH FROM B.fecha_emision) = EXTRACT(MONTH FROM SYSDATE) THEN B.monto_pagado ELSE 0 END) AS mes_actual,
               SUM(CASE WHEN EXTRACT(MONTH FROM B.fecha_emision) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE,-1)) THEN B.monto_pagado ELSE 0 END) AS mes_anterior
        FROM BOLETOS B
        INNER JOIN HORARIOS H ON B.id_horario = H.id_horario
        INNER JOIN PELICULAS P ON H.id_pelicula = P.id_pelicula
        INNER JOIN GENEROS G ON P.id_genero = G.id_genero
        GROUP BY G.nombre_genero
    ) LOOP
        IF rec.mes_anterior > 0 THEN
            v_variacion := ROUND(((rec.mes_actual - rec.mes_anterior) / rec.mes_anterior) * 100, 2);
        ELSE
            v_variacion := 0;
        END IF;
        DBMS_OUTPUT.PUT_LINE(rec.nombre_genero || ' | Mes actual: $' || NVL(ROUND(rec.mes_actual,2),0) || 
                             ' | Mes anterior: $' || NVL(ROUND(rec.mes_anterior,2),0) || ' | Variación: ' || v_variacion || '%');
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO LOG_ERRORES(procedimiento, mensaje_error, usuario_oracle)
        VALUES('sp_indicadores_categoria', SQLERRM, USER);
        COMMIT;
        RAISE;
END;
/

CREATE OR REPLACE PROCEDURE sp_alertas_negocio AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ALERTAS OPERATIVAS ===');
    DBMS_OUTPUT.PUT_LINE('-- Funciones sin ventas próximas 24h:');
    FOR rec IN (
        SELECT P.titulo, S.nombre_sala, H.fecha_hora
        FROM HORARIOS H
        INNER JOIN PELICULAS P ON H.id_pelicula = P.id_pelicula
        INNER JOIN SALAS S ON H.id_sala = S.id_sala
        WHERE H.fecha_hora BETWEEN SYSDATE AND SYSDATE + 1
          AND H.estado = 'PROGRAMADA'
          AND NOT EXISTS (SELECT 1 FROM BOLETOS B WHERE B.id_horario = H.id_horario)
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(' > ' || rec.titulo || ' - ' || rec.nombre_sala || ' - ' || TO_CHAR(rec.fecha_hora,'DD/MM HH24:MI'));
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('-- Salas en mantenimiento con funciones:');
    FOR rec IN (
        SELECT S.nombre_sala, COUNT(H.id_horario) AS funciones_afectadas
        FROM SALAS S
        INNER JOIN HORARIOS H ON S.id_sala = H.id_sala
        WHERE S.estado = 'MANTENIMIENTO' AND H.estado = 'PROGRAMADA'
        GROUP BY S.nombre_sala
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(' > ' || rec.nombre_sala || ' tiene ' || rec.funciones_afectadas || ' función(es) en conflicto.');
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO LOG_ERRORES(procedimiento, mensaje_error, usuario_oracle)
        VALUES('sp_alertas_negocio', SQLERRM, USER);
        COMMIT;
        RAISE;
END;
/

-- ============================================================
-- 7. FUNCIÓN
-- ============================================================

CREATE OR REPLACE FUNCTION fn_calcular_descuento(
    p_id_cliente IN NUMBER,
    p_tipo_boleto IN VARCHAR2,
    p_monto_base IN NUMBER
) RETURN NUMBER IS
    v_antiguedad NUMBER;
    v_descuento NUMBER := 0;
BEGIN
    SELECT NVL(TRUNC(SYSDATE - fecha_registro), 0) INTO v_antiguedad
    FROM CLIENTES WHERE id_cliente = p_id_cliente;
    
    CASE p_tipo_boleto
        WHEN 'ESTUDIANTE' THEN v_descuento := 0.30;
        WHEN 'TERCERA EDAD' THEN v_descuento := 0.40;
        ELSE v_descuento := 0;
    END CASE;
    
    IF v_antiguedad >= 365 THEN
        v_descuento := v_descuento + 0.05;
    END IF;
    
    IF v_descuento > 0.50 THEN
        v_descuento := 0.50;
    END IF;
    
    RETURN ROUND(p_monto_base * (1 - v_descuento), 2);
END;
/

-- ============================================================
-- 8. TRIGGERS (T1, T2)
-- ============================================================

CREATE OR REPLACE TRIGGER trg_auditoria_horarios
    AFTER INSERT OR UPDATE ON HORARIOS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDITORIA(tabla_afectada, accion, usuario_oracle, fecha_hora, valor_nuevo)
        VALUES('HORARIOS', 'INSERT', USER, SYSDATE,
               'id_horario=' || :NEW.id_horario || ', precio_base=' || :NEW.precio_base);
    ELSIF UPDATING THEN
        INSERT INTO AUDITORIA(tabla_afectada, accion, usuario_oracle, fecha_hora, valor_anterior, valor_nuevo)
        VALUES('HORARIOS', 'UPDATE', USER, SYSDATE,
               'precio_base=' || :OLD.precio_base,
               'precio_base=' || :NEW.precio_base);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_validar_disponibilidad
    BEFORE INSERT ON BOLETOS
    FOR EACH ROW
DECLARE
    v_capacidad NUMBER;
    v_vendidos NUMBER;
    v_asiento_dup NUMBER;
BEGIN
    SELECT S.capacidad_asientos INTO v_capacidad
    FROM SALAS S INNER JOIN HORARIOS H ON S.id_sala = H.id_sala
    WHERE H.id_horario = :NEW.id_horario;
    
    SELECT COUNT(*) INTO v_vendidos FROM BOLETOS WHERE id_horario = :NEW.id_horario;
    
    IF v_vendidos >= v_capacidad THEN
        RAISE_APPLICATION_ERROR(-20002, 'La sala está llena.');
    END IF;
    
    SELECT COUNT(*) INTO v_asiento_dup
    FROM BOLETOS WHERE id_horario = :NEW.id_horario AND num_asiento = :NEW.num_asiento;
    
    IF v_asiento_dup > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El asiento ' || :NEW.num_asiento || ' ya está ocupado.');
    END IF;
END;
/

-- ============================================================
-- 9. CURSOR EXPLÍCITO + PROCEDIMIENTO
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_reporte_consolidado_cursor AS
    CURSOR cur_reporte IS
        SELECT P.titulo, COUNT(B.id_boleto) AS total_boletos, SUM(B.monto_pagado) AS total_ingresos
        FROM PELICULAS P
        LEFT JOIN HORARIOS H ON P.id_pelicula = H.id_pelicula
        LEFT JOIN BOLETOS B ON H.id_horario = B.id_horario
        GROUP BY P.titulo;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== REPORTE CONSOLIDADO POR PELÍCULA (CURSOR EXPLÍCITO) ===');
    FOR rec IN cur_reporte LOOP
        DBMS_OUTPUT.PUT_LINE(rec.titulo || ' | Boletos: ' || NVL(rec.total_boletos,0) || ' | $' || NVL(rec.total_ingresos,0));
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        INSERT INTO LOG_ERRORES(procedimiento, mensaje_error, usuario_oracle)
        VALUES('sp_reporte_consolidado_cursor', SQLERRM, USER);
        COMMIT;
        RAISE;
END;
/

-- ============================================================
-- 10. SEGURIDAD (CREAR USUARIOS Y PERMISOS)
-- ============================================================

-- NOTA: Ejecutar como usuario SYSTEM

CREATE USER usr_lectura IDENTIFIED BY "Lectura2026#";
ALTER USER usr_lectura QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION TO usr_lectura;

GRANT SELECT ON GENEROS TO usr_lectura;
GRANT SELECT ON PELICULAS TO usr_lectura;
GRANT SELECT ON SALAS TO usr_lectura;
GRANT SELECT ON HORARIOS TO usr_lectura;
GRANT SELECT ON CLIENTES TO usr_lectura;
GRANT SELECT ON USUARIOS TO usr_lectura;
GRANT SELECT ON BOLETOS TO usr_lectura;

GRANT SELECT ON vw_cartelera_hoy TO usr_lectura;
GRANT SELECT ON vw_reporte_taquilla TO usr_lectura;

CREATE USER usr_admin IDENTIFIED BY "Admin2026#";
ALTER USER usr_admin QUOTA UNLIMITED ON USERS;
GRANT CREATE SESSION TO usr_admin;

GRANT SELECT, INSERT, UPDATE, DELETE ON AUDITORIA TO usr_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON LOG_ERRORES TO usr_admin;

GRANT EXECUTE ON sp_resumen_periodo TO usr_admin;
GRANT EXECUTE ON sp_top_elementos TO usr_admin;
GRANT EXECUTE ON sp_indicadores_categoria TO usr_admin;
GRANT EXECUTE ON sp_alertas_negocio TO usr_admin;
GRANT EXECUTE ON sp_reporte_consolidado_cursor TO usr_admin;
GRANT EXECUTE ON fn_calcular_descuento TO usr_admin;

GRANT SELECT ON GENEROS TO usr_admin;
GRANT SELECT ON PELICULAS TO usr_admin;
GRANT SELECT ON SALAS TO usr_admin;
GRANT SELECT ON HORARIOS TO usr_admin;
GRANT SELECT ON CLIENTES TO usr_admin;