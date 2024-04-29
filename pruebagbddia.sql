-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-04-2024 a las 16:56:54
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `pruebagbddia`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cuentas_insert` ()   BEGIN
INSERT INTO tbl_cuentas
VALUES (nro, tit, fec, sal, act);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_transacciones_insert` ()   BEGIN

DECLARE error_usuario CONDITION FOR SQLSTATE '45000';
DECLARE exit handler FOR error_usuario
BEGIN 
SHOW ERRORS;
ROLLBACK;
END;

DECLARE exit handler FOR SQLEXCEPTION
BEGIN
SELECT 0;
ROLLBACK;
END;

DECLARE exit handler FOR SQLWARNING
BEGIN 
SELECT 0;
ROLLBACK;
END;

START TRANSACTION;
INSERT INTO tbl_transacciones
VALUES( noTr, noCta, fecTr, valTr, 1 );
COMMIT;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_cuentas`
--

CREATE TABLE `tbl_cuentas` (
  `CodigoCuenta` int(11) NOT NULL,
  `titularCuenta` varchar(100) DEFAULT NULL,
  `fechaAperturaCuenta` date DEFAULT NULL,
  `saldoCuenta` double DEFAULT NULL,
  `activaCuenta` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbl_transacciones`
--

CREATE TABLE `tbl_transacciones` (
  `nroTransacciones` int(11) NOT NULL,
  `codCuenta` int(11) DEFAULT NULL,
  `fechaTransaccion` date DEFAULT NULL,
  `valor` double DEFAULT NULL,
  `anuladaSN` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `tbl_transacciones`
--
DELIMITER $$
CREATE TRIGGER `tbl_transacciones_after_insert` AFTER INSERT ON `tbl_transacciones` FOR EACH ROW BEGIN
UPDATE tbl_cuentas CTA 
SET SALDOCUENTA = SALDOCUENTA + NEW.valor;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tbl_transacciones_before_insert` BEFORE INSERT ON `tbl_transacciones` FOR EACH ROW BEGIN
DECLARE V_SALDO DOUBLE DEFAULT 0;

DECLARE  YA_LLEGO BOOL DEFAULT FALSE;
DECLARE CONSULTA CURSOR FOR SELECT CTA.saldoCuenta
FROM tbl_cuentas CTA
WHERE CTA.codigoCuenta = NEW.codCuenta;

DECLARE CONTINUE handler FOR NOT FOUND SET YA_LLEGO = TRUE;

OPEN CONSULTA;
fetch CONSULTA	INTO V_SALDO;

if ( YA_LLEGO ) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se encontro la cuenta';
ELSE
if (V_SALDO + NEW.valor) < 0 then
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Saldo insuficiente para el retiro';
END if;
END if;
close CONSULTA;
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `tbl_cuentas`
--
ALTER TABLE `tbl_cuentas`
  ADD PRIMARY KEY (`CodigoCuenta`);

--
-- Indices de la tabla `tbl_transacciones`
--
ALTER TABLE `tbl_transacciones`
  ADD PRIMARY KEY (`nroTransacciones`),
  ADD KEY `codCuenta` (`codCuenta`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `tbl_cuentas`
--
ALTER TABLE `tbl_cuentas`
  MODIFY `CodigoCuenta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tbl_transacciones`
--
ALTER TABLE `tbl_transacciones`
  MODIFY `nroTransacciones` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tbl_transacciones`
--
ALTER TABLE `tbl_transacciones`
  ADD CONSTRAINT `FK_tbl_Transacciones_tbl_cuentas` FOREIGN KEY (`codCuenta`) REFERENCES `tbl_cuentas` (`CodigoCuenta`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
