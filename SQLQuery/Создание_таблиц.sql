CREATE TABLE Ресурс (
    id_Ресурс INT IDENTITY(1,1) PRIMARY KEY
);

CREATE TABLE Жанр (
    id_Жанр INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    id_Родительский_жанр INT NULL,

    FOREIGN KEY (id_Родительский_жанр)
        REFERENCES Жанр(id_Жанр)
);

CREATE TABLE Издательство (
    id_Издательство INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    город NVARCHAR(100) NULL,
    страна NVARCHAR(100) NULL
);

CREATE TABLE Журнал (
    id_Журнал INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL
);

CREATE TABLE Тип_Хранения (
    id_Тип_Хранения INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(100) NOT NULL
);

CREATE TABLE Формат_Хранения (
    id_Формат INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(100) NOT NULL,
    описание NVARCHAR(MAX) NULL
);

CREATE TABLE Филиал (
    id_Филиал INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    город NVARCHAR(100) NOT NULL,
    улица NVARCHAR(100) NOT NULL,
    дом NVARCHAR(20) NOT NULL,
    индекс VARCHAR(20) NULL
);

CREATE TABLE Книга (
    id_Ресурс INT PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    год_издания INT NULL,
    количество_страниц INT NULL,
    аннотация NVARCHAR(MAX) NULL,
    ISBN NVARCHAR(17) UNIQUE NULL,
    id_Жанр INT NOT NULL,
    id_Издательство INT NOT NULL,

    FOREIGN KEY (id_Ресурс)
        REFERENCES Ресурс(id_Ресурс),

    FOREIGN KEY (id_Жанр)
        REFERENCES Жанр(id_Жанр),

    FOREIGN KEY (id_Издательство)
        REFERENCES Издательство(id_Издательство)
);

CREATE TABLE Автор (
    id_Автор INT IDENTITY(1,1) PRIMARY KEY,
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    отчество NVARCHAR(100) NULL,
    год_рождения INT NULL,
    год_смерти INT NULL
);

CREATE TABLE Автор_Книга (
    id_Автор INT NOT NULL,
    id_Ресурс INT NOT NULL,

    PRIMARY KEY (id_Автор, id_Ресурс),

    FOREIGN KEY (id_Автор)
        REFERENCES Автор(id_Автор),

    FOREIGN KEY (id_Ресурс)
        REFERENCES Книга(id_Ресурс)
);

CREATE TABLE Выпуск (
    id_Ресурс INT PRIMARY KEY,
    номер INT NOT NULL,
    год_выпуска INT NOT NULL,
    id_Журнал INT NOT NULL,

    FOREIGN KEY (id_Ресурс)
        REFERENCES Ресурс(id_Ресурс),

    FOREIGN KEY (id_Журнал)
        REFERENCES Журнал(id_Журнал)
);

CREATE TABLE Статья (
    id_Статья INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    страница_с INT NOT NULL,
    страница_по INT NOT NULL,
    аннотация NVARCHAR(MAX) NULL,
    id_Ресурс INT NOT NULL,

    FOREIGN KEY (id_Ресурс)
        REFERENCES Выпуск(id_Ресурс)
);

CREATE TABLE Автор_Статья (
    id_Автор INT NOT NULL,
    id_Статья INT NOT NULL,

    PRIMARY KEY (id_Автор, id_Статья),

    FOREIGN KEY (id_Автор)
        REFERENCES Автор(id_Автор),

    FOREIGN KEY (id_Статья)
        REFERENCES Статья(id_Статья)
);

CREATE TABLE Представление_Ресурса (
    id_Представление INT IDENTITY(1,1) PRIMARY KEY,
    id_Ресурс INT NOT NULL,
    id_Формат INT NOT NULL,
    id_Тип_Хранения INT NOT NULL,

    FOREIGN KEY (id_Ресурс)
        REFERENCES Ресурс(id_Ресурс),

    FOREIGN KEY (id_Формат)
        REFERENCES Формат_Хранения(id_Формат),

    FOREIGN KEY (id_Тип_Хранения)
        REFERENCES Тип_Хранения(id_Тип_Хранения)
);

CREATE TABLE Физический_Экземпляр (
    id_Экземпляр INT IDENTITY(1,1) PRIMARY KEY,
    инвентарный_номер NVARCHAR(50) UNIQUE NOT NULL,
    статус NVARCHAR(50) NOT NULL,
    id_Представление INT NOT NULL,
    id_Отдел INT NOT NULL,

    CHECK (статус IN (
        N'доступен',
        N'выдан',
        N'утерян',
        N'списан'
    )),

    FOREIGN KEY (id_Представление)
        REFERENCES Представление_Ресурса(id_Представление)
);

CREATE TABLE Электронный_Ресурс (
    id_Электронный_Ресурс INT IDENTITY(1,1) PRIMARY KEY,
    статус NVARCHAR(50) NOT NULL,
    размер_файла DECIMAL(10,2) NULL,
    id_Представление INT NOT NULL,

    CHECK (статус IN (
        N'доступен',
        N'архивирован',
        N'удален'
    )),

    FOREIGN KEY (id_Представление)
        REFERENCES Представление_Ресурса(id_Представление)
);

CREATE TABLE Отдел (
    id_Отдел INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    id_Филиал INT NOT NULL,

    FOREIGN KEY (id_Филиал)
        REFERENCES Филиал(id_Филиал)
);

ALTER TABLE Физический_Экземпляр
ADD CONSTRAINT FK_Физический_Экземпляр_Отдел
FOREIGN KEY (id_Отдел)
    REFERENCES Отдел(id_Отдел);

CREATE TABLE Личность (
    id_Личность INT IDENTITY(1,1) PRIMARY KEY,
    фамилия NVARCHAR(100) NOT NULL,
    имя NVARCHAR(100) NOT NULL,
    отчество NVARCHAR(100) NULL,
    город NVARCHAR(100) NULL,
    улица NVARCHAR(100) NULL,
    дом NVARCHAR(20) NULL,
    телефон NVARCHAR(20) NULL,
    email NVARCHAR(255) UNIQUE NULL
);

CREATE TABLE Читатель (
    id_Личность INT PRIMARY KEY,
    номер_читательского_билета NVARCHAR(50) UNIQUE NOT NULL,
    дата_регистрации DATE NOT NULL,
    статус NVARCHAR(50) NOT NULL,

    CHECK (статус IN (
        N'активен',
        N'заблокирован'
    )),

    FOREIGN KEY (id_Личность)
        REFERENCES Личность(id_Личность)
);

CREATE TABLE Сотрудник (
    id_Личность INT PRIMARY KEY,
    должность NVARCHAR(100) NOT NULL,
    дата_приема_на_работу DATE NOT NULL,
    id_Отдел INT NOT NULL,

    FOREIGN KEY (id_Личность)
        REFERENCES Личность(id_Личность),

    FOREIGN KEY (id_Отдел)
        REFERENCES Отдел(id_Отдел)
);

CREATE TABLE Пользователь (
    id_Пользователь INT IDENTITY(1,1) PRIMARY KEY,
    логин NVARCHAR(100) UNIQUE NOT NULL,
    пароль NVARCHAR(255) NOT NULL,
    роль NVARCHAR(50) NOT NULL,
    id_Личность INT UNIQUE NOT NULL,

    CHECK (роль IN (
        N'администратор',
        N'библиотекарь'
    )),

    FOREIGN KEY (id_Личность)
        REFERENCES Личность(id_Личность)
);

CREATE TABLE Выдача (
    id_Выдача INT IDENTITY(1,1) PRIMARY KEY,
    дата_выдачи DATE NOT NULL,
    срок_возврата DATE NOT NULL,
    дата_возврата DATE NULL,
    id_Экземпляр INT NOT NULL,
    id_Читатель INT NOT NULL,
    id_Сотрудник INT NOT NULL,

    FOREIGN KEY (id_Экземпляр)
        REFERENCES Физический_Экземпляр(id_Экземпляр),

    FOREIGN KEY (id_Читатель)
        REFERENCES Читатель(id_Личность),

    FOREIGN KEY (id_Сотрудник)
        REFERENCES Сотрудник(id_Личность)
);

CREATE TABLE Движение_Фонда (
    id_Движение INT IDENTITY(1,1) PRIMARY KEY,
    тип_операции NVARCHAR(50) NOT NULL,
    дата_операции DATE NOT NULL,
    примечание NVARCHAR(MAX) NULL,
    id_Экземпляр INT NOT NULL,
    id_Сотрудник INT NOT NULL,

    CHECK (тип_операции IN (
        N'поступление',
        N'перемещение',
        N'списание'
    )),

    FOREIGN KEY (id_Экземпляр)
        REFERENCES Физический_Экземпляр(id_Экземпляр),

    FOREIGN KEY (id_Сотрудник)
        REFERENCES Сотрудник(id_Личность)
);