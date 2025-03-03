# Test
Стартовый проект для тестового задания в команду Рейтингов и Отзывов ВК.

## Пример выполненного задания:

![скриншот](https://github.com/DzhamiRakhmetov/Test-task/blob/main/screenShot_photo.png)

## Загрузка данных
- Для получения отзывов используется **async/await**.

## Кэширование изображений
- Изображения кэшируются с использованием **NSCache**.

## Многопоточность
- Для выполнения асинхронных операций используется конструкция **Task**, которая обеспечивает безопасное выполнение кода на фоновых потоках и обновление UI на главном потоке через **@MainActor**.

## Ключевые проблемы UI-перформанса в UITableView

### Переиспользование ячеек
- Лучше использовать **reuseIdentifier** для ячеек.
- Минимизировать data binding в `cellForRowAtIndexPath`.
- Стоит перенести настройку данных в `willDisplayCell`.

### Вычисление высоты ячеек
- Лучше использовать простые арифметические операции.
- Стоит избегать создания экземпляров ячеек и сложных вычислений в `heightForRowAtIndexPath`.

### Оптимизация Auto Layout
- Лучше свести к минимуму количество constraints и глубину иерархии view.
- Стоит рассмотреть ручное задание фреймов для динамических ячеек.

### Offscreen Rendering и Overdraw
- Лучше избегать прозрачных фонов, теней без `shadowPath` и масок.
- Стоит установить `opaque = YES` и использовать инструменты (например, Color Blended Layers) для выявления проблем.

### Субпиксельное выравнивание
- Лучше применять `CGRectIntegral`, `ceilf` и `floorf` для округления координат и предотвращения ненужного субпиксельного антиалиасинга.

### Баланс CPU и GPU
- Лучше перенести тяжелые операции (например, рендеринг и обработку изображений) на CPU для разгрузки GPU и поддержания 60 FPS.
