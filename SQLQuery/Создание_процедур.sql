-- Процедура чтение
CREATE PROCEDURE sp_ПолучитьКнигиАвтора
    @Фамилия NVARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        К.название AS Книга,

        STRING_AGG(
            А2.фамилия + N' ' +
            А2.имя +
            CASE
                WHEN А2.отчество IS NOT NULL
                THEN N' ' + А2.отчество
                ELSE N''
            END,
            N', '
        ) AS Авторы,

        Ж.название AS Жанр,

        И.название AS Издательство,

        ФЭ.инвентарный_номер,

        ФЭ.статус,

        О.название AS Отдел

    FROM Автор А

    INNER JOIN Автор_Книга АК
        ON А.id_Автор = АК.id_Автор

    INNER JOIN Книга К
        ON АК.id_Ресурс = К.id_Ресурс

    INNER JOIN Автор_Книга АК2
        ON К.id_Ресурс = АК2.id_Ресурс

    INNER JOIN Автор А2
        ON АК2.id_Автор = А2.id_Автор

    INNER JOIN Жанр Ж
        ON К.id_Жанр = Ж.id_Жанр

    INNER JOIN Издательство И
        ON К.id_Издательство = И.id_Издательство

    INNER JOIN Представление_Ресурса ПР
        ON К.id_Ресурс = ПР.id_Ресурс

    INNER JOIN Физический_Экземпляр ФЭ
        ON ПР.id_Представление = ФЭ.id_Представление

    INNER JOIN Отдел О
        ON ФЭ.id_Отдел = О.id_Отдел

    WHERE А.фамилия = @Фамилия

    GROUP BY
        К.название,
        Ж.название,
        И.название,
        ФЭ.инвентарный_номер,
        ФЭ.статус,
        О.название;

END;
GO

CREATE PROCEDURE sp_ПолучитьРесурсыАвтора
    @Фамилия NVARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        К.название AS Книга,

        STRING_AGG(
            А2.фамилия + N' ' +
            А2.имя +
            CASE
                WHEN А2.отчество IS NOT NULL
                THEN N' ' + А2.отчество
                ELSE N''
            END,
            N', '
        ) AS Авторы,

        ФХ.название AS Формат,

        ТХ.название AS ТипХранения,

        ФЭ.инвентарный_номер,

        ФЭ.статус AS СтатусФизическогоЭкземпляра,

        ЭР.статус AS СтатусЭлектронногоРесурса,

        О.название AS Отдел

    FROM Автор А

    INNER JOIN Автор_Книга АК
        ON А.id_Автор = АК.id_Автор

    INNER JOIN Книга К
        ON АК.id_Ресурс = К.id_Ресурс

    INNER JOIN Автор_Книга АК2
        ON К.id_Ресурс = АК2.id_Ресурс

    INNER JOIN Автор А2
        ON АК2.id_Автор = А2.id_Автор

    INNER JOIN Представление_Ресурса ПР
        ON К.id_Ресурс = ПР.id_Ресурс

    INNER JOIN Формат_Хранения ФХ
        ON ПР.id_Формат = ФХ.id_Формат

    INNER JOIN Тип_Хранения ТХ
        ON ПР.id_Тип_Хранения = ТХ.id_Тип_Хранения

    LEFT JOIN Физический_Экземпляр ФЭ
        ON ПР.id_Представление = ФЭ.id_Представление

    LEFT JOIN Электронный_Ресурс ЭР
        ON ПР.id_Представление = ЭР.id_Представление

    LEFT JOIN Отдел О
        ON ФЭ.id_Отдел = О.id_Отдел

    WHERE А.фамилия = @Фамилия

    GROUP BY
        К.название,
        ФХ.название,
        ТХ.название,
        ФЭ.инвентарный_номер,
        ФЭ.статус,
        ЭР.статус,
        О.название;

END;
GO

-- процедура модификация/записи

CREATE PROCEDURE sp_ОформитьВыдачу
(
    @id_Экземпляр INT,
    @id_Читатель INT,
    @id_Сотрудник INT,
    @КоличествоДней INT
)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Проверка существования экземпляра
        IF NOT EXISTS
        (
            SELECT 1
            FROM Физический_Экземпляр
            WHERE id_Экземпляр = @id_Экземпляр
        )
        BEGIN
            RAISERROR(N'Экземпляр не существует.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Проверка статуса экземпляра
        IF EXISTS
        (
            SELECT 1
            FROM Физический_Экземпляр
            WHERE id_Экземпляр = @id_Экземпляр
              AND статус <> N'доступен'
        )
        BEGIN
            RAISERROR(N'Экземпляр недоступен для выдачи.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Проверка статуса читателя
        IF EXISTS
        (
            SELECT 1
            FROM Читатель
            WHERE id_Личность = @id_Читатель
              AND статус = N'заблокирован'
        )
        BEGIN
            RAISERROR(N'Читатель заблокирован.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Создание записи выдачи
        INSERT INTO Выдача
        (
            дата_выдачи,
            срок_возврата,
            дата_возврата,
            id_Экземпляр,
            id_Читатель,
            id_Сотрудник
        )
        VALUES
        (
            GETDATE(),
            DATEADD(DAY, @КоличествоДней, GETDATE()),
            NULL,
            @id_Экземпляр,
            @id_Читатель,
            @id_Сотрудник
        );

        -- Обновление статуса экземпляра
        UPDATE Физический_Экземпляр
        SET статус = N'выдан'
        WHERE id_Экземпляр = @id_Экземпляр;

        COMMIT TRANSACTION;

        PRINT N'Выдача успешно оформлена.';

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        PRINT N'Ошибка при оформлении выдачи.';
        PRINT ERROR_MESSAGE();

    END CATCH;

END;
GO



-- анализ/статистика

CREATE PROCEDURE sp_АнализПопулярности
AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        К.название AS Книга,

        STRING_AGG(
            А.фамилия + N' ' + А.имя,
            N', '
        ) AS Авторы,

        COUNT(В.id_Выдача) AS [Количество выдач]

    FROM Книга К

    INNER JOIN Автор_Книга АК
        ON К.id_Ресурс = АК.id_Ресурс

    INNER JOIN Автор А
        ON АК.id_Автор = А.id_Автор

    INNER JOIN Представление_Ресурса ПР
        ON К.id_Ресурс = ПР.id_Ресурс

    INNER JOIN Физический_Экземпляр ФЭ
        ON ПР.id_Представление = ФЭ.id_Представление

    LEFT JOIN Выдача В
        ON ФЭ.id_Экземпляр = В.id_Экземпляр

    GROUP BY
        К.id_Ресурс,
        К.название

    ORDER BY
        [Количество выдач] DESC;

END;
GO