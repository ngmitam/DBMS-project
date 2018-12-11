-- phpMyAdmin SQL Dump
-- version 4.8.0.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: localhost
-- Thời gian đã tạo: Th10 19, 2018 lúc 02:33 PM
-- Phiên bản máy phục vụ: 10.1.32-MariaDB
-- Phiên bản PHP: 7.2.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `chat`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addChat` (IN `roomid` INT, IN `userid` INT, IN `content` TEXT CHARSET utf8)  NO SQL
BEGIN
    START TRANSACTION
        ;
    INSERT INTO `chat`(
        `chat`.`ROOM_ID`,
        `chat`.`USER_ID`,
        `chat`.`CHAT_CONTENT`
    )
    VALUES(roomid, userid, content);
    UPDATE
        `user_room`
    SET
        `user_room`.`USER_ROOM_TIME` = TIMESTAMP(NOW())
    WHERE
        `user_room`.`ROOM_ID` = roomid;
    COMMIT
        ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addRoom` (IN `user1id` INT, IN `user2id` INT)  NO SQL
BEGIN
    START TRANSACTION
        ;
    INSERT INTO `room`
    VALUES();
    SELECT
        @id := LAST_INSERT_ID();
    INSERT INTO `user_room`(
        `user_room`.`USER_ID`,
        `user_room`.`ROOM_ID`,
        `user_room`.`USER_ROOM_STATUS`
    )
    VALUES(user1id, @id, 0);
    INSERT INTO `user_room`(
        `user_room`.`USER_ID`,
        `user_room`.`ROOM_ID`,
        `user_room`.`USER_ROOM_STATUS`
    )
    VALUES(user2id, @id, 1);
    COMMIT
        ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkFriend` (IN `userid` INT, IN `friendid` INT)  NO SQL
BEGIN
    SELECT
        *
    FROM
        (
        SELECT
            `user_room`.`ROOM_ID`,
            `user_room`.`USER_ID`,
            `user`.`USER_NAME`,
            `user_room`.`USER_ROOM_STATUS`,
            `user_room`.`USER_ROOM_TIME`
        FROM
            (
            SELECT
                `user_room`.`ROOM_ID` AS room_id
            FROM
                `user_room`
            WHERE
                `user_room`.`USER_ID` = userid
        ) AS a
    INNER JOIN `user_room` ON(a.room_id = `user_room`.`ROOM_ID`)
    INNER JOIN `user` ON(
            `user_room`.`USER_ID` = `user`.`USER_ID`
        )
    WHERE NOT
        (`user_room`.`USER_ID` = userid)
    ) AS b
    WHERE
        b.`USER_ID` = friendid;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkLogin` (IN `username` TEXT CHARSET utf8)  NO SQL
BEGIN
    SELECT
        *
    FROM
        `user`
    WHERE
        `user`.`USER_NAME` = username;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `register` (IN `username` TEXT CHARSET utf8, IN `password` TEXT CHARSET utf8, IN `fullname` TEXT CHARSET utf8, IN `email` TEXT CHARSET utf8, IN `face` TEXT CHARSET utf8)  NO SQL
    SQL SECURITY INVOKER
BEGIN
    START TRANSACTION
        ;
    INSERT INTO `person`(
        `person`.`PERSON_FULLNAME`,
        `person`.`PERSON_EMAIL`,
        `person`.`PERSON_FACE`
    )
    VALUES(
        fullname,
        (SELECT 
         	LOWER(email)
   	),
        face
    );
    INSERT INTO `user`(
        `user`.`USER_NAME`,
        `user`.`USER_PASSWORD`,
        `user`.`PERSON_ID`,
        `user`.`USER_LASTACTION`
    )
    VALUES(
        username,
        password,
        LAST_INSERT_ID(),
        TIMESTAMP(NOW()));
    
    COMMIT
        ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `searchFriend` (IN `userid` INT, IN `s` TEXT CHARSET utf8)  NO SQL
BEGIN
    SELECT
        `user_room`.`ROOM_ID`,
        `user_room`.`USER_ID`,
        `user`.`USER_NAME`,
        `user_room`.`USER_ROOM_STATUS`,
        `user_room`.`USER_ROOM_TIME`
    FROM
        (
        SELECT
            `user_room`.`ROOM_ID` AS room_id
        FROM
            `user_room`
        WHERE
            `user_room`.`USER_ID` = userid
    ) AS a
    INNER JOIN `user_room` ON
        (a.room_id = `user_room`.`ROOM_ID`)
    INNER JOIN `user` ON
        (
            `user_room`.`USER_ID` = `user`.`USER_ID`
        )
    WHERE NOT
        (`user_room`.`USER_ID` = userid) AND `user`.`USER_NAME` like CONCAT("%",s,"%")
    ORDER BY
        `user_room`.`USER_ROOM_TIME`
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectLast5Chat` (IN `roomid` INT, IN `chatid` INT)  NO SQL
BEGIN
    SELECT
        *
    FROM
        `chat`
    WHERE
        `chat`.`ROOM_ID` = roomid AND `chat`.`CHAT_ID` < chatid
    ORDER BY
        `chat`.`CHAT_ID`
    DESC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectNewestChat` (IN `roomid` INT, IN `chatid` INT)  NO SQL
BEGIN
    SELECT
        *
    FROM
        `chat`
    WHERE
        `chat`.`ROOM_ID` = roomid AND `chat`.`CHAT_ID` > chatid
    ORDER BY
        `chat`.`CHAT_ID`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectNewestFriend` (IN `userid` INT, IN `time` TIMESTAMP)  NO SQL
BEGIN
    SELECT
        `user_room`.`ROOM_ID`,
        `user_room`.`USER_ID`,
        `user`.`USER_NAME`,
        `user_room`.`USER_ROOM_STATUS`,
        `user_room`.`USER_ROOM_TIME`
    FROM
        (
        SELECT
            `user_room`.`ROOM_ID` AS room_id
        FROM
            `user_room`
        WHERE
            `user_room`.`USER_ID` = userid
    ) AS a
    INNER JOIN `user_room` ON
        (a.room_id = `user_room`.`ROOM_ID`)
    INNER JOIN `user` ON
        (
            `user_room`.`USER_ID` = `user`.`USER_ID`
        )
    WHERE NOT
        (`user_room`.`USER_ID` = userid) AND `user_room`.`USER_ROOM_TIME` > time
    ORDER BY
        `user_room`.`USER_ROOM_TIME`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectTop10Chat` (IN `roomid` INT)  NO SQL
BEGIN
    SELECT
        *
    FROM
        `chat`
    WHERE
        `chat`.`ROOM_ID` = roomid
    ORDER BY
        `chat`.`CHAT_ID`
    DESC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `selectTop10Friend` (IN `userid` INT)  NO SQL
BEGIN
    SELECT
        `user_room`.`ROOM_ID`,
        `user_room`.`USER_ID`,
        `user`.`USER_NAME`,
        `user_room`.`USER_ROOM_STATUS`,
        `user_room`.`USER_ROOM_TIME`
    FROM
        (
        SELECT
            `user_room`.`ROOM_ID` AS room_id
        FROM
            `user_room`
        WHERE
            `user_room`.`USER_ID` = userid
    ) AS a
    INNER JOIN `user_room` ON
        (a.room_id = `user_room`.`ROOM_ID`)
    INNER JOIN `user` ON
        (
            `user_room`.`USER_ID` = `user`.`USER_ID`
        )
    WHERE NOT
        (`user_room`.`USER_ID` = userid)
    ORDER BY
        `user_room`.`USER_ROOM_TIME`
    DESC
    LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateUserRoomStatus` (IN `userid` INT, IN `roomid` INT, IN `status` INT)  NO SQL
BEGIN
    UPDATE
        `user_room`
    SET
        `user_room`.`USER_ROOM_STATUS` = status
    WHERE
        `user_room`.`USER_ID` = userid AND `user_room`.`ROOM_ID` = roomid;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat`
--

CREATE TABLE `chat` (
  `CHAT_ID` int(11) NOT NULL,
  `ROOM_ID` int(11) DEFAULT NULL,
  `USER_ID` int(11) DEFAULT NULL,
  `CHAT_CONTENT` text,
  `CHAT_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `chat`
--

INSERT INTO `chat` (`CHAT_ID`, `ROOM_ID`, `USER_ID`, `CHAT_CONTENT`, `CHAT_TIME`) VALUES
(1, 1, 2, 'Chào Admin', '2018-11-19 13:22:35');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `person`
--

CREATE TABLE `person` (
  `PERSON_ID` int(11) NOT NULL,
  `PERSON_FULLNAME` text,
  `PERSON_EMAIL` text,
  `PERSON_FACE` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `person`
--

INSERT INTO `person` (`PERSON_ID`, `PERSON_FULLNAME`, `PERSON_EMAIL`, `PERSON_FACE`) VALUES
(1, 'admin', 'admin@admin.com', 'admin'),
(2, 'test1', 'test1@test.com', 'test1');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `room`
--

CREATE TABLE `room` (
  `ROOM_ID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `room`
--

INSERT INTO `room` (`ROOM_ID`) VALUES
(1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user`
--

CREATE TABLE `user` (
  `USER_ID` int(11) NOT NULL,
  `USER_NAME` text,
  `USER_PASSWORD` text,
  `PERSON_ID` int(11) DEFAULT NULL,
  `USER_LASTACTION` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `user`
--

INSERT INTO `user` (`USER_ID`, `USER_NAME`, `USER_PASSWORD`, `PERSON_ID`, `USER_LASTACTION`) VALUES
(1, 'admin', '$2y$10$ySezHcM/V2d0i6XJX8SrfuJklvTDI1bZqQ3kfF71QFtXII4TNhCPW', 1, '2018-11-19 13:18:56'),
(2, 'test1', '$2y$10$whRQ2r3spQResM22QcSB9OGV7cGeRwOXJKeJqW3RlYJneZZSCTN1q', 2, '2018-11-19 13:21:32');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user_room`
--

CREATE TABLE `user_room` (
  `USER_ID` int(11) NOT NULL,
  `ROOM_ID` int(11) NOT NULL,
  `USER_ROOM_STATUS` int(11) DEFAULT NULL,
  `USER_ROOM_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Đang đổ dữ liệu cho bảng `user_room`
--

INSERT INTO `user_room` (`USER_ID`, `ROOM_ID`, `USER_ROOM_STATUS`, `USER_ROOM_TIME`) VALUES
(1, 1, 1, '2018-11-19 13:22:35'),
(2, 1, 0, '2018-11-19 13:22:35');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`CHAT_ID`),
  ADD KEY `USER_ID` (`USER_ID`,`ROOM_ID`);

--
-- Chỉ mục cho bảng `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`PERSON_ID`);

--
-- Chỉ mục cho bảng `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`ROOM_ID`);

--
-- Chỉ mục cho bảng `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`USER_ID`),
  ADD KEY `FK_USER_PERSON` (`PERSON_ID`);

--
-- Chỉ mục cho bảng `user_room`
--
ALTER TABLE `user_room`
  ADD PRIMARY KEY (`USER_ID`,`ROOM_ID`),
  ADD KEY `FK_ROOM_USER_ROOM` (`ROOM_ID`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `chat`
--
ALTER TABLE `chat`
  MODIFY `CHAT_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `person`
--
ALTER TABLE `person`
  MODIFY `PERSON_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `room`
--
ALTER TABLE `room`
  MODIFY `ROOM_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `user`
--
ALTER TABLE `user`
  MODIFY `USER_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `chat`
--
ALTER TABLE `chat`
  ADD CONSTRAINT `chat_ibfk_1` FOREIGN KEY (`USER_ID`,`ROOM_ID`) REFERENCES `user_room` (`USER_ID`, `ROOM_ID`);

--
-- Các ràng buộc cho bảng `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `FK_USER_PERSON` FOREIGN KEY (`PERSON_ID`) REFERENCES `person` (`PERSON_ID`);

--
-- Các ràng buộc cho bảng `user_room`
--
ALTER TABLE `user_room`
  ADD CONSTRAINT `FK_ROOM_USER_ROOM` FOREIGN KEY (`ROOM_ID`) REFERENCES `room` (`ROOM_ID`),
  ADD CONSTRAINT `FK_USER_USER_ROOM` FOREIGN KEY (`USER_ID`) REFERENCES `user` (`USER_ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
