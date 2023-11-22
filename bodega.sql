-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 22-11-2023 a las 16:02:18
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bodega`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entrada`
--

CREATE TABLE `entrada` (
  `Cant_entrada` int(11) NOT NULL,
  `Codigo_prod` int(11) NOT NULL,
  `Fecha_entrada` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `entrada`
--

INSERT INTO `entrada` (`Cant_entrada`, `Codigo_prod`, `Fecha_entrada`) VALUES
(10, 1, '2023-11-22');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `Codigo` int(11) NOT NULL,
  `Nombre` varchar(100) NOT NULL,
  `Precio` decimal(10,2) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Fecha_de_vencimiento` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`Codigo`, `Nombre`, `Precio`, `Cantidad`, `Fecha_de_vencimiento`) VALUES
(1, 'Gomitas', 2000.00, 40, '2024-10-14'),
(2, 'Harina', 2500.00, 62, '2024-07-19');

--
-- Disparadores `productos`
--
DELIMITER $$
CREATE TRIGGER `t_after_delete_producto` AFTER DELETE ON `productos` FOR EACH ROW BEGIN
    INSERT INTO salida (Cant_salida, Codigo_prod, fecha_salida)
    VALUES (OLD.Cantidad, OLD.Codigo, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t_after_insert_producto` AFTER INSERT ON `productos` FOR EACH ROW BEGIN
    INSERT INTO entrada (Cant_entrada, Codigo_prod, fecha_entrada)
    VALUES (NEW.Cantidad, NEW.Codigo, NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `t_after_update_producto` AFTER UPDATE ON `productos` FOR EACH ROW BEGIN
    IF NEW.Cantidad > OLD.Cantidad THEN
        INSERT INTO entrada (Cant_entrada, Codigo_prod, fecha_entrada)
        VALUES (NEW.Cantidad - OLD.Cantidad, NEW.Codigo, NOW());
    ELSEIF NEW.Cantidad < OLD.Cantidad THEN
        INSERT INTO salida (Cant_salida, Codigo_prod, fecha_salida)
        VALUES (OLD.Cantidad - NEW.Cantidad, NEW.Codigo, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `salida`
--

CREATE TABLE `salida` (
  `Codigo_prod` int(11) NOT NULL,
  `Cant_salida` int(15) NOT NULL,
  `Fecha_salida` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `salida`
--

INSERT INTO `salida` (`Codigo_prod`, `Cant_salida`, `Fecha_salida`) VALUES
(1, 10, '2023-11-22');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `entrada`
--
ALTER TABLE `entrada`
  ADD KEY `fk_ent_prod` (`Codigo_prod`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`Codigo`);

--
-- Indices de la tabla `salida`
--
ALTER TABLE `salida`
  ADD KEY `fk_sal_prod` (`Codigo_prod`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `Codigo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `entrada`
--
ALTER TABLE `entrada`
  ADD CONSTRAINT `fk_ent_prod` FOREIGN KEY (`Codigo_prod`) REFERENCES `productos` (`Codigo`);

--
-- Filtros para la tabla `salida`
--
ALTER TABLE `salida`
  ADD CONSTRAINT `fk_sal_prod` FOREIGN KEY (`Codigo_prod`) REFERENCES `productos` (`Codigo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
