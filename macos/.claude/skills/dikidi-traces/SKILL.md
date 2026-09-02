---
name: dikidi-traces
description: Скачивание и разбор трейсов Яндекс Мониторинга (dikidi). Использовать, когда нужно понять, где потрачено время в запросе — есть trace id или ссылка вида monitoring.yandex-team.ru/projects/*/traces/<id>. Умеет качать трейс через API и раскладывать по фазам jOOQ, отличая ожидание пула от блокировки в базе и от пауз JVM.
---

# Разбор трейсов dikidi

## Почему не MCP

У `mcp__monium_mcp__read_trace` быстро кончается квота (429 после ~десятка
трейсов) и он отдаёт многословный текст на 150+ КБ. HTTP-ручка отдаёт компактный
JSON и квотой не ограничена.

## Скачать трейс

Токен: `~/.dikidi-tokens/monium`. Не печатать его в вывод — только через env.

```bash
export MONIUM_TOKEN="$(cat ~/.dikidi-tokens/monium)"
curl -sS 'https://monitoring.yandex-team.ru/api/gateway/root/tracing/getTrace' \
  -X POST \
  -H "Authorization: OAuth $MONIUM_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'x-client-id: monitoring-ui-internal' \
  --data-raw '{"traceId":"<TRACE_ID>","organizationId":""}' \
  -o trace.json
```

Работает для любого проекта, включая `dikidi_backend_restricted`.

## Найти трейсы по условию (listTraces)

Когда trace id заранее неизвестен — например «все SSR-рендеры дольше 500мс за
сутки». Время здесь в **миллисекундах** (`fromMillis`/`toMillis`), в отличие от
`getTrace`, где метки в микросекундах.

```bash
curl -sS 'https://monitoring.yandex-team.ru/api/gateway/root/tracing/listTraces' \
  -X POST \
  -H "Authorization: OAuth $MONIUM_TOKEN" \
  -H 'Content-Type: application/json' \
  -H 'x-client-id: monitoring-ui-internal' \
  --data-raw '{
    "fromMillis": 1786893578927,
    "toMillis":   1786979978927,
    "query": "{project = \"dikidi_front\", service = \"frontend_workload\", cluster = \"dikidi-front-production.frontend\", span.name = \"POST /ssr/render\", span.duration > 500ms}",
    "pageSize": 20,
    "withoutTraceSummary": false
  }' \
  -o traces.json
```

В `query` — селектор в фигурных скобках: обычные метки (`project`, `service`,
`cluster`) плюс `span.name` и `span.duration` с суффиксом времени (`500ms`, `2s`).

Ответ: `tracesMetadata[]`, в каждом элементе `traceId`, `traceDurationMillis`,
`startTimeMillis`, `rootService`, `rootOperation` и `services[]` со счётчиками
спанов и ошибок. Дальше id скармливать `getTrace`.

Подбирать поля запроса наугад не надо: на любой недочёт ручка отвечает
`400 from_us field is required` независимо от настоящей причины — сообщение
бесполезное и сбивает с толку.

## Структура ответа

`spans` — **плоский** список (поле `children` содержит id, а не вложенные
объекты). У спана: `id`, `parentSpanId`, `name`, `service`, `cluster`, `kind`,
`startTimeUs`, `durationUs`, `labels`.

## Разбор

Скрипт рядом: `analyze.py`. Запуск: `python3 analyze.py trace.json [...]`

## Как читать фазы jOOQ

`JooqSpanExecuteListener` пишет длительности фаз в `db.jooq.*_us`. Норма и
о чём говорит отклонение:

| фаза | норма | аномалия означает |
|---|---|---|
| `render_us` | 30–110 мкс | CPU-фаза, строка собирается в памяти → **встал поток JVM** (GC, throttling) |
| `prepare_us` | 20–30 мкс | сюда входит получение коннекта → **ожидание пула HikariCP** |
| `execute_us` | 1–15 мс | round-trip в базу → **блокировка или тяжёлый запрос** |

Важно: длительность спана включает ещё и маппинг результата, поэтому
`duration - сумма фаз` — это время вне jOOQ (маппинг либо та же пауза JVM).

## Ловушки

- **Окружение смотреть по `deployment.environment.name`, а не по `cluster`.**
  В testing метка `cluster` проставлена как `production` — это баг разметки.
- **Отсутствие спанов `l7`** означает запрос напрямую в под, минуя балансер.
  Органика всегда идёт через l7, так что такой трейс — чей-то ручной запрос
  или нагрузочный тест. Проверять, не свой ли, прежде чем делать выводы.
- Одновременный конец нескольких долгих спанов по одной таблице при разном
  старте — очередь на блокировке, а не медленный запрос.
- **Долгий спан HTTP-клиента в Node ≠ медленный бекенд.** Спан меряет wall-time
  и впитывает простой event loop. Различать по вложенному спану `l7` и событиям
  `http.client.response.headers`/`.end`:
  - `l7`-ребёнок стартовал намного позже родителя → поток стоял *до* отправки
    (запрос не смогли записать в сокет);
  - `l7` закончился быстро, а `response.headers` сработало намного позже → ответ
    лежал в сокете, поток стоял *после* получения.

  В обоих случаях бекенд ни при чём. Подтверждать метрикой
  `nodejs.event_loop_lag.max.milliseconds` по нужному поду.
- **Не считать «время бекенда» только по спанам `l7`.** В части трейсов слоя l7
  для API-вызовов нет, а спаны `dikidi-api` висят отдельными корнями — суммируя
  только l7, получишь бекенд «0мс» на запросе, где база реально работала.
  Объединять интервалы по спанам `dikidi-api` тоже, а не вместо.
- **Синтетика: trace id задаётся только заголовком `traceparent`.** Формат
  `00-<32hex>-<16hex>-01`. Свой `x-request-id` трейс не создаёт (в органике он
  совпадает с trace id лишь потому, что его проставляет l7), а запрос без
  `traceparent` вообще не сэмплируется — спанов не будет. Задавать id самому
  удобно: потом сразу `getTrace` по known id.
- **При стрельбе издалека внешние спаны раздуты отдачей ответа.** `POST
  /ssr/render` и `request handler` включают запись тела клиенту: 200 КБ на канал
  с RTT 165мс — это +250мс к спану при 100мс реального рендера. Чистое время
  брать по `ssr.island`.
- Заблокированный поток **без расхода CPU** (высокий `event_loop_lag` при низком
  `cpu.usage.cores`, нулевых `cpu.throttled.cores` и `cpu.*_wait.cores`) — это
  синхронный блокирующий syscall, а не нехватка процессора. GC проверять по
  `nodejs.gc.duration.milliseconds` — паузы попадают в бакеты по длительности.
