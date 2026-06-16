# Defensa del frontend FestCine

## Indice rapido

- [Resumen general](#resumen-general)
- [Como fluye la informacion](#como-fluye-la-informacion)
- [Estructura real de carpetas](#estructura-real-de-carpetas)
- [Guia archivo por archivo](#guia-archivo-por-archivo)
- [Mapa de pantallas](#mapa-de-pantallas)
- [Si quiero modificar X, donde voy](#si-quiero-modificar-x-donde-voy)
- [Servicios y API](#servicios-y-api)
- [Modelos del frontend](#modelos-del-frontend)
- [Widgets compartidos](#widgets-compartidos)
- [Flujos importantes](#flujos-importantes)
- [Advertencias tecnicas](#advertencias-tecnicas)
- [Idea clave para la defensa](#idea-clave-para-la-defensa)

## Resumen general

FestCine es el frontend Flutter Web del sistema de gestion de un festival de cine. La app permite iniciar con perfil de cajero o administrador y, segun el perfil, acceder a dashboard, taquilla, eventos, agenda, reportes, peliculas y ediciones.

El frontend no se conecta directamente a SQL Server ni ejecuta consultas SQL. Su trabajo es mostrar pantallas, capturar datos del usuario, validar lo basico antes de enviar formularios y consumir un backend ASP.NET Core. El backend es quien habla con SQL Server, aplica reglas de negocio y devuelve respuestas HTTP.

La modularizacion actual divide el proyecto en capas claras:

- `app/`: arranque visual, tema, login, shell y navegacion.
- `features/`: pantallas funcionales visibles por el usuario.
- `data/`: conexion HTTP, parseo JSON, catalogos API y datos fallback.
- `domain/models/`: clases que representan conceptos del dominio.
- `shared/widgets/`: componentes visuales reutilizables.
- `core/utils/`: funciones puras para texto, fechas, IDs, asientos y reglas.

## Como fluye la informacion

El flujo normal de datos es:

```text
Usuario -> Pagina Flutter -> DatabaseGateway -> Backend ASP.NET Core -> SQL Server
```

Ejemplo concreto: cuando el cajero vende una entrada, la pantalla `TaquillaPage` junta pelicula, funcion, asiento, persona, tarifa y pago. Luego llama a `DatabaseGateway.p1ComprarEntrada`. Ese metodo envia un `POST /api/taquilla/comprar-entrada`. El backend registra compra, entrada y factura, y el frontend muestra el resultado.

La URL base del backend esta en `lib/data/api_config.dart`:

```text
http://localhost:5075
```

Tambien puede cambiarse al compilar usando `API_BASE_URL`.

## Estructura real de carpetas

Arbol actual de `lib/`:

```text
lib/
  main.dart
  app/
    auth_gate.dart
    enums.dart
    fest_cine_app.dart
    shell.dart
    theme.dart
  core/
    utils/
      edition_rules.dart
      fuzzy_utils.dart
      id_utils.dart
      merge_utils.dart
      room_utils.dart
      seat_utils.dart
      text_utils.dart
      time_utils.dart
  data/
    api_catalog.dart
    api_config.dart
    database_exception.dart
    database_gateway.dart
    json_helpers.dart
    mappers.dart
    fallback/
      catalogs.dart
  domain/
    models/
      domain_models.dart
      report_models.dart
  features/
    agenda/
      agenda_page.dart
    dashboard/
      dashboard_page.dart
    ediciones/
      admin_editions_page.dart
    eventos/
      admin_events_page.dart
      event_ticket_page.dart
    peliculas/
      admin_movies_page.dart
    reportes/
      reportes_page.dart
    taquilla/
      taquilla_page.dart
  shared/
    widgets/
      common_widgets.dart
      style_helpers.dart
```

Nota tecnica: los archivos Dart estan organizados con `part`/`part of` desde `lib/main.dart`. Eso mantiene una sola libreria Dart y permite que las clases privadas con `_` sigan funcionando despues de modularizar. Si algun dia se migra a imports normales, habra que revisar nombres privados.

## Guia archivo por archivo

| Archivo | Responsabilidad | Clases o funciones principales | Cuando modificarlo | Que no tocar sin cuidado |
| --- | --- | --- | --- | --- |
| `lib/main.dart` | Punto de entrada de la app y declaracion de partes. | `main()` | Si se agrega o remueve un archivo `part`. | No poner logica de pantalla aqui otra vez. |
| `lib/app/fest_cine_app.dart` | Widget raiz y configuracion global de `MaterialApp`. | `FestCineApp` | Si cambia el titulo, tema global o pantalla inicial. | No cambiar `home: AuthGate()` sin revisar login y shell. |
| `lib/app/theme.dart` | Paleta, radios y tema visual de Material. | colores `bg`, `gold`, `surface`, `appInputBorder` | Si quieres cambiar colores, bordes o estilos globales. | Cambiar colores altera toda la identidad visual. |
| `lib/app/enums.dart` | Enumeraciones globales de navegacion, roles y modo de venta. | `Module`, `UserRole`, `SaleMode` | Si se agrega un modulo o perfil. | Cambiar nombres rompe `switch` y navegacion. |
| `lib/app/auth_gate.dart` | Login simple por perfil y control de sesion local. | `AuthGate`, `LoginPage` | Si cambia la seleccion de cajero/admin o textos del login. | No meter autenticacion real sin revisar backend. |
| `lib/app/shell.dart` | Layout principal, menu lateral, topbar, seleccion de modulo y carga de catalogos. | `Shell`, `_Sidebar`, `_Topbar`, `_loadApiCatalog`, `_selectEdition` | Si cambia el menu, permisos por rol o catalogos iniciales. | No duplicar estado de catalogos en pantallas hijas sin necesidad. |
| `lib/features/dashboard/dashboard_page.dart` | Pantalla de resumen general por edicion. | `DashboardPage` | Si cambian metricas, tarjetas o selector de edicion. | No cambiar llamadas a reportes sin revisar `DatabaseGateway`. |
| `lib/features/taquilla/taquilla_page.dart` | Venta de entradas y abonos. | `TaquillaPage`, `_confirmPurchase`, `_confirmSubscriptionPurchase` | Si cambian formularios de taquilla, validaciones o pasos de venta. | Es una pantalla sensible: probar compra, abonos, acreditados y asientos. |
| `lib/features/eventos/event_ticket_page.dart` | Venta de entradas para eventos paralelos. | `EventTicketPage`, `_confirm` | Si cambia el flujo de venta de eventos. | No saltar validacion de aforo. |
| `lib/features/eventos/admin_events_page.dart` | Administracion y creacion de eventos. | `AdminEventsPage`, `_createEvent` | Si cambian campos de evento, sala, fecha u hora. | No cambiar reglas de edicion activa/pasada sin revisar `edition_rules.dart`. |
| `lib/features/agenda/agenda_page.dart` | Control de agenda y proyecciones. | `AgendaPage`, `_addScreening` | Si cambian salas, peliculas, horarios o creacion de proyecciones. | No crear proyecciones sin `idSala` e `idPeliculaEdicion`. |
| `lib/features/reportes/reportes_page.dart` | Reportes de ranking, premiacion y finanzas. | `ReportesPage` | Si cambia como se muestran reportes. | No alterar calculos que vienen del backend sin revisar endpoints. |
| `lib/features/peliculas/admin_movies_page.dart` | Administracion y creacion de peliculas. | `AdminMoviesPage`, `_createMovie` | Si cambian campos de pelicula, generos o director. | No romper relacion pelicula-edicion-genero-director. |
| `lib/features/ediciones/admin_editions_page.dart` | Creacion de ediciones, categorias, jurados y patrocinio. | `AdminEditionsPage`, `_saveEdition`, `_openJurorDialog` | Si cambia el formulario de edicion o sus relaciones. | Cuidado con sede-edicion, categorias, jurados y patrocinadores. |
| `lib/shared/widgets/common_widgets.dart` | Widgets reutilizables de UI. | `CardBox`, `ResponsiveGrid`, `Header`, `SeatMap`, `GenericQr`, dialogos, chips | Si se quiere cambiar un componente visual usado en varias pantallas. | Un cambio aqui puede afectar muchas pantallas. |
| `lib/shared/widgets/style_helpers.dart` | Colores derivados para salas, tarjetas y paletas. | `roomColor`, `paletteFor`, `cardFillFor` | Si cambia la codificacion visual de salas o cards. | Cambiar aqui altera apariencia global de componentes. |
| `lib/data/api_config.dart` | Configuracion HTTP comun. | `apiBaseUrl`, `apiTimeout` | Si cambia host del backend o timeout. | No hardcodear otro entorno sin entender despliegue. |
| `lib/data/database_gateway.dart` | Capa de comunicacion con backend. | `DatabaseGateway` y sus metodos publicos | Si cambia un endpoint, payload o nuevo caso API. | No cambiar contratos JSON sin revisar backend. |
| `lib/data/database_exception.dart` | Error controlado para mensajes del backend. | `DatabaseException` | Si cambia la forma de mostrar errores tecnicos. | No mostrar detalles internos innecesarios al usuario final. |
| `lib/data/api_catalog.dart` | Resultado compuesto de catalogos iniciales. | `ApiCatalog` | Si `fetchCatalog` devuelve nuevos catalogos. | Mantener coherencia con `Shell`. |
| `lib/data/json_helpers.dart` | Lectura tolerante de JSON. | `_readString`, `_readInt`, `_readDouble`, `_readBool`, `_readDate` | Si el backend cambia nombres o tipos de campos. | No romper soporte camelCase/PascalCase. |
| `lib/data/mappers.dart` | Conversores de JSON a modelos. | `dashboardFromJson`, `attendeeFromJson`, `festivalEventFromJson` | Si cambia la respuesta JSON del backend. | No inventar campos que no devuelve la API. |
| `lib/data/fallback/catalogs.dart` | Datos fallback para modo local o backend no disponible. | `fallbackAttendees`, `fallbackEditions`, `initialMovies`, `baseSchedule` | Solo si se actualizan datos demo existentes. | No agregar datos falsos sin autorizacion. |
| `lib/domain/models/domain_models.dart` | Modelos principales del dominio. | `Movie`, `Session`, `FestivalEvent`, `Attendee`, `FestivalEdition`, drafts y opciones | Si cambia un concepto de negocio usado por pantallas. | Cambiar constructores rompe muchas llamadas. |
| `lib/domain/models/report_models.dart` | Modelos de compras, dashboard y reportes. | `PurchaseReceipt`, `DashboardMetrics`, `ReportBundle` | Si cambian reportes o recibos. | No cambiar nombres si el UI ya los usa. |
| `lib/core/utils/time_utils.dart` | Fechas, horas y conversion de minutos. | `formatApiDay`, `formatApiTime`, `toMinutes` | Si cambia formato de fecha/hora. | No romper formato esperado por backend. |
| `lib/core/utils/seat_utils.dart` | Conversion entre asiento visual y numero. | `seatLabelToNumber`, `seatNumberToLabel` | Si cambia la grilla de asientos. | Afecta compra de entrada y asientos ocupados. |
| `lib/core/utils/id_utils.dart` | Generacion de IDs locales segun listas actuales. | `nextProjectionId`, `nextIdFromMaps`, `idSalaForRoom` | Si cambia convencion de IDs. | No cambiar prefijos sin backend/base de datos. |
| `lib/core/utils/edition_rules.dart` | Reglas para bloquear eventos fuera de ediciones validas. | `_editionAllowsEventCreation`, `_editionBlockReason`, `_eventDateBlockReason` | Si cambian reglas de edicion activa, planificada o pasada. | Validar con negocio antes de relajar reglas. |
| `lib/core/utils/text_utils.dart` | Normalizacion de texto, telefonos y nombres. | `normalizeText`, `onlyDigits`, `toTitleCase`, `splitFullName` | Si cambia busqueda de personas o nombres. | Puede afectar deteccion de duplicados. |
| `lib/core/utils/merge_utils.dart` | Union de catalogos del backend con fallback. | `mergeCategoryOptions`, `mergeGenreOptions`, `mergeDirectorOptions` | Si cambia como se mezclan catalogos. | No duplicar opciones por nombre normalizado. |
| `lib/core/utils/fuzzy_utils.dart` | Comparacion simple por tokens. | `fuzzyScore` | Si cambia la busqueda aproximada de personas/directores. | Probar falsos positivos y duplicados. |
| `lib/core/utils/room_utils.dart` | Capacidad por nombre de sala fallback. | `roomCapacity` | Si cambian capacidades demo. | No usarlo como verdad si backend trae capacidad real. |

## Mapa de pantallas

### Login o seleccion de perfil

- Archivo: `lib/app/auth_gate.dart`.
- Que hace: permite entrar como cajero o administrador.
- Datos: no consume backend; guarda el rol en estado local.
- Widgets: `CardBox`, `BadgeIcon`, botones Material.
- Cambiar texto visible: en `LoginPage`.
- Cambiar validacion o autenticacion: crear una integracion real y revisar `AuthGate`.

### Dashboard

- Archivo: `lib/features/dashboard/dashboard_page.dart`.
- Que hace: muestra resumen de la edicion seleccionada.
- Datos: metricas, ranking, premiacion, finanzas, peliculas vendidas y proyecciones.
- Servicios: `DatabaseGateway.fetchDashboardBundle`.
- Modelos: `DashboardBundle`, `DashboardMetrics`, `RankingItem`, `AwardItem`, `FinanceItem`, `SoldMovie`, `ProjectionSummary`, `FestivalEdition`.
- Widgets: `Header`, `CardBox`, `StatCard`, `ProgressRow`, `AlertBanner`, `ResponsiveGrid`.
- Cambiar texto visible: `dashboard_page.dart`.
- Cambiar llamada al backend: `fetchDashboardBundle` en `database_gateway.dart`.

### Taquilla: venta de entradas

- Archivo: `lib/features/taquilla/taquilla_page.dart`.
- Que hace: guia al cajero por pelicula, funcion, asiento, persona, tarifa, pago y confirmacion.
- Datos: peliculas, funciones, asistentes, personas, abonos, acreditaciones y tarifas.
- Servicios: `resolveAttendee`, `p1ComprarEntrada`, `fetchAttendeePasses`, `fetchAttendeeAccreditation`, `ensureAccreditation`.
- Modelos: `Movie`, `Session`, `Attendee`, `PersonOption`, `PurchaseReceipt`, `OwnedPass`, `ActiveAccreditation`, `AccreditationType`.
- Widgets: `MovieCard`, `SeatMap`, `StepperPills`, `CardBox`, `GenericQr`, `StatusChip`, `AlertBanner`.
- Cambiar texto visible: buscar el texto en `taquilla_page.dart`.
- Cambiar validacion: revisar `_attendeeFormValid`, `_confirmPurchase` y helpers cercanos.
- Cambiar backend: revisar los metodos de `DatabaseGateway` usados por la pantalla.

### Taquilla: venta de abonos

- Archivo: `lib/features/taquilla/taquilla_page.dart`.
- Que hace: vende un abono a un asistente resuelto o creado.
- Datos: tipos de abono, persona/asistente, tarifa, pago y NIT.
- Servicios: `resolveAttendee` y `venderAbono`.
- Modelos: `SubscriptionType`, `AttendeeFormData`, `ResolvedAttendee`, `PurchaseReceipt`.
- Cambiar texto del boton de confirmacion: buscar el texto visible en `taquilla_page.dart`.
- Cambiar endpoint: `DatabaseGateway.venderAbono`.

### Venta de entradas para eventos

- Archivo: `lib/features/eventos/event_ticket_page.dart`.
- Que hace: vende entradas para eventos paralelos de la edicion.
- Datos: eventos, aforo vendido, persona/asistente, pago y factura.
- Servicios: `resolveAttendee` y `venderEntradaEvento`.
- Modelos: `FestivalEvent`, `Attendee`, `PersonOption`, `PurchaseReceipt`.
- Widgets: `CardBox`, `AlertBanner`, `GenericQr`, `StatusChip`.
- Cambiar validacion: revisar `_personFormValid` y `_confirm`.
- Cambiar endpoint: `DatabaseGateway.venderEntradaEvento`.

### Eventos admin

- Archivo: `lib/features/eventos/admin_events_page.dart`.
- Que hace: lista eventos y permite crear nuevos eventos.
- Datos: eventos, salas, ediciones y edicion seleccionada.
- Servicios: `createFestivalEvent`.
- Modelos: `FestivalEvent`, `EventDraft`, `RoomOption`, `FestivalEdition`.
- Widgets: `Header`, `CardBox`, `StatusChip`, `AlertBanner`.
- Cambiar reglas de fecha/edicion: `core/utils/edition_rules.dart`.
- Cambiar llamada backend: `DatabaseGateway.createFestivalEvent`.

### Peliculas

- Archivo: `lib/features/peliculas/admin_movies_page.dart`.
- Que hace: muestra cartelera y permite crear peliculas con generos y director.
- Datos: peliculas, generos, directores, personas y edicion.
- Servicios: `createMovieForEdition`.
- Modelos: `Movie`, `MovieDraft`, `GenreOption`, `DirectorOption`, `PersonOption`.
- Widgets: `MovieCard`, `GenrePickerDialog`, `DirectorFormDialog`, `RemovableChip`, `CardBox`.
- Cambiar tarjeta de pelicula: `MovieCard` en `shared/widgets/common_widgets.dart`.
- Cambiar creacion de director: `DatabaseGateway.createMovieForEdition` y `_resolveDirectorId`.

### Ediciones

- Archivo: `lib/features/ediciones/admin_editions_page.dart`.
- Que hace: crea ediciones, categorias, jurados y patrocinio.
- Datos: sedes, peliculas, categorias, jurados y patrocinadores.
- Servicios: `createFestivalEdition` y `createJuror`.
- Modelos: `FestivalEditionDraft`, `CategoryOption`, `JuryDraft`, `SponsorDraft`, `VenueOption`, `MovieOption`.
- Widgets: `CategoryPickerDialog`, `JuryFormDialog`, `RemovableChip`, `CardBox`, `AlertBanner`.
- Cambiar formulario: `admin_editions_page.dart`.
- Cambiar payload: `DatabaseGateway.createFestivalEdition`.

### Agenda

- Archivo: `lib/features/agenda/agenda_page.dart`.
- Que hace: permite crear y listar proyecciones.
- Datos: peliculas, salas, dias, horarios y agenda actual.
- Servicios: `insertProjection`.
- Modelos: `ScreeningPlan`, `Movie`, `RoomOption`.
- Widgets: `CardBox`, `Legend`, `StatusChip`, `AlertBanner`.
- Cambiar horario o formato de agenda: `agenda_page.dart`.
- Cambiar endpoint: `DatabaseGateway.insertProjection`.

### Reportes

- Archivo: `lib/features/reportes/reportes_page.dart`.
- Que hace: muestra ranking, premiacion y resumen financiero.
- Datos: `ReportBundle` por edicion.
- Servicios: `fetchReportBundle`.
- Modelos: `RankingItem`, `AwardItem`, `FinanceItem`, `ReportBundle`.
- Widgets: `CardBox`, `ResponsiveGrid`, `ProgressRow`, `AlertBanner`.
- Cambiar graficos/listas: `reportes_page.dart`.
- Cambiar datos: endpoints de reportes en `DatabaseGateway`.

## Si quiero modificar X, donde voy

| Quiero modificar | Ir a | Comentario practico |
| --- | --- | --- |
| Texto del menu lateral | `lib/app/shell.dart` | Busca `_navForRole`; ahi estan etiquetas como `Dashboard`, `Taquilla`, `Eventos`. |
| Color principal | `lib/app/theme.dart` | Cambia `gold`, `burgundy` o la configuracion de `ColorScheme`, sabiendo que afecta toda la app. |
| Endpoint base de la API | `lib/data/api_config.dart` | Cambia `apiBaseUrl` o compila con `--dart-define=API_BASE_URL=...`. |
| Texto de un boton | Archivo de la pantalla que lo muestra | Por ejemplo, botones de taquilla estan en `taquilla_page.dart`. |
| Validacion del formulario de taquilla | `lib/features/taquilla/taquilla_page.dart` | Revisa `_attendeeFormValid`, `_confirmPurchase`, `_confirmSubscriptionPurchase`. |
| Como se muestran peliculas | `lib/shared/widgets/common_widgets.dart` y `lib/features/peliculas/admin_movies_page.dart` | La tarjeta reutilizable es `MovieCard`. |
| Como se crean directores | `lib/data/database_gateway.dart` | Revisa `createMovieForEdition`, `_resolveDirectorId` y `_resolveDirectorRoleId`. |
| Logica de QR | `lib/shared/widgets/common_widgets.dart` | Widget `GenericQr`; actualmente es visual/generico. |
| Logica de acreditado/VIP | `lib/features/taquilla/taquilla_page.dart` y `DatabaseGateway` | Revisa acreditacion, abonos permitidos y `ensureAccreditation`. |
| Creacion de eventos | `lib/features/eventos/admin_events_page.dart` y `DatabaseGateway.createFestivalEvent` | Las reglas de fecha estan en `edition_rules.dart`. |
| Venta de entradas para eventos | `lib/features/eventos/event_ticket_page.dart` y `DatabaseGateway.venderEntradaEvento` | Aforo y compra se manejan ahi. |
| Dashboard | `lib/features/dashboard/dashboard_page.dart` | La carga viene de `fetchDashboardBundle`. |
| Reportes | `lib/features/reportes/reportes_page.dart` | La carga viene de `fetchReportBundle`. |
| Modelos o parseo JSON | `lib/domain/models/` y `lib/data/mappers.dart` | Cambia modelos y mappers juntos si cambia la API. |
| Asientos ocupados | `lib/data/mappers.dart`, `lib/core/utils/seat_utils.dart`, `SeatMap` | La API devuelve numero; el UI usa etiqueta como `A1`. |
| Error mostrado al usuario | `lib/data/database_exception.dart` y `_friendlyMessage` en `DatabaseGateway` | El frontend busca `mensaje`, `message` o `error`. |

## Servicios y API

La comunicacion con el backend esta concentrada en `lib/data/database_gateway.dart`. Usa `http.Client`, JSON con `jsonEncode/jsonDecode`, timeout de 8 segundos y la URL base de `apiBaseUrl`.

| Metodo | Endpoints principales | Payload que envia | Respuesta esperada | Pantallas que lo usan |
| --- | --- | --- | --- | --- |
| `fetchCatalog({editionId})` | `GET /api/ediciones`, `/api/catalogos/peliculas/{id}`, `/api/catalogos/proyecciones/{id}`, `/api/asistentes`, `/api/personas`, `/api/entradas-individuales`, `/api/catalogos/salas/{id}`, `/api/catalogos/eventos/{id}`, `/api/catalogos/tarifas`, `/api/catalogos/generos`, `/api/sedes`, `/api/peliculas`, `/api/relaciones/pelicula-generos`, `/api/participaciones-pelicula`, `/api/personal-cinematografico`, `/api/roles-cinematograficos`, `/api/jurados`, `/api/categorias-competicion`, `/api/patrocinadores`, `/api/tipo-abonos`, `/api/tipo-acreditaciones` | No envia body; usa `editionId` en rutas. | `ApiCatalog` con catalogos listos para UI. | `Shell` al iniciar y cambiar edicion. |
| `fetchReportBundle(editionId)` | `GET /api/dashboard/{id}`, `/api/reportes/ranking/{id}`, `/api/reportes/premiacion/{id}`, `/api/reportes/financiero/{id}` | No envia body. | `ReportBundle`. | `ReportesPage`, indirectamente dashboard. |
| `fetchDashboardBundle(editionId)` | Usa `fetchReportBundle`, `GET /api/catalogos/proyecciones/{id}`, `GET /api/entradas-individuales` | No envia body. | `DashboardBundle` con metricas, ranking, finanzas, top vendido y proyecciones. | `DashboardPage`. |
| `p1ComprarEntrada` | `POST /api/taquilla/comprar-entrada` | `idAsistente`, `idProyeccion`, `idTarifa`, `metodoPago`, `nit`, `nombreCompra`, `nroAsiento`. | `PurchaseReceipt` con compra, entrada, factura, codigo, monto y metodo. | `TaquillaPage`. |
| `fetchAttendeePasses` | `GET /api/abonos-crud`, `GET /api/relaciones/abono-proyecciones` | No envia body; filtra por asistente y proyeccion. | Lista de `OwnedPass` con `allowed`. | `TaquillaPage`. |
| `venderAbono` | `POST /api/abonos/vender` | `idAsistente`, `idTipoAbono`, `idTarifa`, `metodoPago`, `nit`, `nombreCompra`, `pagoAprobado`. | `PurchaseReceipt` con codigo de abono/factura. | `TaquillaPage`. |
| `venderEntradaEvento` | `GET /api/entradas-individuales`, `/api/compras`, `/api/facturas`; `POST /api/compras`, `/api/entradas-individuales`, `/api/facturas` | Compra, entrada de evento y factura generadas desde el frontend. | `PurchaseReceipt`. | `EventTicketPage`. |
| `resolveAttendee` | `GET /api/personas`, `GET /api/asistentes`, `POST /api/personas`, `POST /api/asistentes` | Datos de `AttendeeFormData` y `editionId`. | `ResolvedAttendee` indicando si se creo o reutilizo. | `TaquillaPage`, `EventTicketPage`. |
| `createJuror` | `GET /api/personas`, `GET /api/jurados`, `POST /api/personas`, `POST /api/jurados` | Datos de `JuryDraft`. | `JuryMember`. | `AdminEditionsPage`. |
| `createMovieForEdition` | `GET /api/peliculas`, `/api/pelicula-ediciones`, `/api/catalogos/generos`, `/api/relaciones/pelicula-generos`, `/api/personas`, `/api/personal-cinematografico`, `/api/roles-cinematograficos`, `/api/participaciones-pelicula`; varios `POST` relacionados | Datos de `MovieDraft`, generos, director y edicion. | `Movie` creado para insertarlo en la lista. | `AdminMoviesPage`. |
| `insertProjection` | `POST /api/agenda/proyecciones` | `idProyeccion`, `fechaHoraInicio`, `tieneQA`, `idSala`, `idPeliculaEdicion`. | Sin modelo de respuesta relevante. | `AgendaPage`. |
| `createFestivalEvent` | `GET /api/eventos-paralelos`, `POST /api/agenda/eventos` | Datos de `EventDraft`: evento, tipo, descripcion, aforo, costo, fecha, duracion, edicion y sala. | `FestivalEvent`. | `AdminEventsPage`. |
| `createFestivalEdition` | `GET /api/ediciones`, `/api/pelicula-ediciones`, `/api/categorias-competicion`, `/api/patrocinadores`, `/api/patrocinios`; `POST /api/ediciones`, `/api/sede-ediciones`, `/api/patrocinadores`, `/api/patrocinios`, `/api/pelicula-ediciones`, `/api/categorias-competicion`, `/api/relaciones/categoria-jurados` | Datos de `FestivalEditionDraft`. | `String` con `idEdicion`. | `AdminEditionsPage`. |
| `fetchAttendeeAccreditation` | `GET /api/acreditaciones` | No envia body; filtra por asistente. | `ActiveAccreditation?`. | `TaquillaPage`. |
| `ensureAccreditation` | `GET /api/acreditaciones`, `POST /api/acreditaciones` o `PUT /api/acreditaciones/{id}` | Asistente y tipo de acreditacion. | `ActiveAccreditation`. | `TaquillaPage`. |

Metodos privados importantes dentro del gateway:

- `_getMap`, `_getList`, `_postJson`, `_putJson`: helpers HTTP.
- `_uri`: arma la URL con `apiBaseUrl`.
- `_friendlyMessage`: extrae `mensaje`, `message` o `error` del backend.
- `_idTarifa`: resuelve el ID de tarifa por tipo.

## Modelos del frontend

| Modelo | Que representa | Concepto/tablas relacionadas | Campos principales | Donde se usa | Mapper JSON |
| --- | --- | --- | --- | --- | --- |
| `Movie` | Pelicula visible en cartelera. | Pelicula, pelicula-edicion, generos, director. | titulo, genero, duracion, clasificacion, pais, sinopsis, sesiones, IDs. | Taquilla, peliculas, agenda. | Armado en `fetchCatalog`; creacion en `createMovieForEdition`. |
| `Session` | Funcion/proyeccion de una pelicula. | Proyeccion, sala, entradas. | fecha, hora, sala, QA, ocupados, idProyeccion, idSala, capacidad. | Taquilla y asientos. | En `fetchCatalog`. |
| `ScreeningPlan` | Proyeccion para agenda. | Proyeccion, pelicula-edicion, sala. | pelicula, sala, dia, hora, duracion, QA, IDs. | Agenda. | En `fetchCatalog` y `insertProjection`. |
| `RoomOption` | Sala seleccionable. | Sala y sede. | id, nombre, sede, capacidad. | Eventos, agenda, catalogos. | En `fetchCatalog`. |
| `FestivalEvent` | Evento paralelo del festival. | Eventos paralelos, entradas de evento. | id, nombre, tipo, descripcion, aforo, costo, inicio, duracion, edicion, sala, vendidos. | Eventos admin y venta de eventos. | `festivalEventFromJson`. |
| `EventDraft` | Datos antes de crear evento. | Payload de evento. | nombre, tipo, descripcion, capacidad, costo, fecha, hora, sala. | `AdminEventsPage`. | No viene de JSON; se arma desde formulario. |
| `Attendee` | Asistente registrado. | Persona y Asistente. | idAsistente, nombre, correo, idPersona, nombres, telefono. | Taquilla y eventos. | `attendeeFromJson`, `attendeeFromPersonAndAssistant`. |
| `PersonOption` | Persona candidata o existente. | Persona. | idPersona, nombre, apellido, correo, telefono. | Busquedas y formularios. | `personOptionFromJson`. |
| `PersonMatch` | Coincidencia persona-asistente. | Persona + Asistente. | persona, asistente opcional. | Taquilla y eventos. | No directo. |
| `ResolvedAttendee` | Resultado de resolver/crear asistente. | Persona + Asistente. | creado, attendee. | Compras y eventos. | Devuelto por `resolveAttendee`. |
| `AttendeeFormData` | Datos capturados del formulario de persona. | Persona/Asistente. | idPersona, nombre, apellido, correo, telefono. | Taquilla y eventos. | No directo. |
| `VenueOption` | Sede seleccionable. | Sede. | id, nombre, ciudad. | Ediciones. | En `fetchCatalog`. |
| `MovieOption` | Pelicula ligera para seleccion. | Pelicula. | id, titulo, anio. | Ediciones y agenda. | En `fetchCatalog`. |
| `CategoryOption` | Categoria de competicion. | CategoriaCompeticion. | id, nombre, descripcion, edicion. | Ediciones. | `categoryOptionFromJson`. |
| `GenreOption` | Genero de pelicula. | Genero. | id, nombre, `isLocal`. | Peliculas. | En `fetchCatalog`. |
| `DirectorOption` | Director/personal cinematografico. | Persona + PersonalCinematografico + Rol. | id, nombre, pais, biografia, telefono, `isLocal`. | Peliculas. | `directorsFromStaff`. |
| `MovieDraft` | Datos antes de crear pelicula. | Pelicula, generos, director, edicion. | titulo, anio, duracion, pais, sinopsis, formato, generos, director. | `AdminMoviesPage`. | No directo. |
| `JuryMember` | Jurado visible. | Jurado + Persona. | id, nombre, rol. | Ediciones. | En `fetchCatalog` y `createJuror`. |
| `JuryDraft` | Datos antes de crear jurado. | Persona + Jurado. | nombre, correo, telefono, especialidad, tipo. | Dialogo de jurado. | No directo. |
| `SponsorOption` | Patrocinador. | Patrocinador. | id, nombre, telefono, correo. | Ediciones. | `sponsorFromJson`. |
| `SubscriptionType` | Tipo de abono. | TipoAbono. | id, nombre, descripcion, precio. | Taquilla. | `subscriptionTypeFromJson`. |
| `AccreditationType` | Tipo de acreditacion. | TipoAcreditacion. | id, nombre. | Taquilla. | `accreditationTypeFromJson`. |
| `ActiveAccreditation` | Acreditacion activa o existente de un asistente. | Acreditacion. | id, asistente, tipo, nombre tipo, estado. | Taquilla. | `activeAccreditationFromJson`. |
| `OwnedPass` | Abono que posee un asistente. | Abono y AbonoProyeccion. | id, codigo, tipo, estado, permitido. | Taquilla acreditado. | Armado en `fetchAttendeePasses`. |
| `FestivalEdition` | Edicion del festival. | Edicion. | id, nombre, fecha inicio, fecha fin, estado. | Shell, dashboard, eventos, reportes. | `editionFromJson`. |
| `FestivalEditionDraft` | Datos antes de crear edicion. | Edicion, sede-edicion, categorias, peliculas, patrocinio. | nombre, fechas, estado, sede, peliculas, categorias, jurados, sponsor. | `AdminEditionsPage`. | No directo. |
| `SponsorDraft` | Datos antes de crear patrocinio. | Patrocinador + Patrocinio. | sponsor existente/nuevo, tipo aporte, monto, descripcion. | Ediciones. | No directo. |
| `PurchaseReceipt` | Resumen de compra/factura. | Compra, Entrada, Factura, Abono. | idCompra, idEntrada, idFactura, codigo, monto, metodo. | Taquilla y eventos. | Respuestas de venta. |
| `DashboardMetrics` | Numeros principales del dashboard. | Dashboard/reportes backend. | peliculas, proyecciones, asistentes, entradas, abonos, recaudacion. | Dashboard. | `dashboardFromJson`. |
| `RankingItem` | Ranking de ocupacion. | Reporte ranking. | pelicula, proyecciones, capacidad, asistentes, porcentaje. | Dashboard y reportes. | `rankingFromJson`. |
| `AwardItem` | Resultado de premiacion. | Reporte premiacion. | categoria, premio, titulo, evaluaciones, promedio. | Reportes. | `awardFromJson`. |
| `FinanceItem` | Resumen financiero. | Reporte financiero. | tipo venta, subtipo, tarifa, cantidad, total. | Reportes. | `financeFromJson`. |
| `SoldMovie` | Conteo de ventas por pelicula. | Entradas + proyecciones. | titulo, ventas. | Dashboard. | Armado en `fetchDashboardBundle`. |
| `ProjectionSummary` | Resumen de proyeccion. | Proyeccion. | titulo, sala, fecha/hora. | Dashboard. | Armado en `fetchDashboardBundle`. |
| `ReportBundle` | Conjunto de reportes. | Dashboard + ranking + premiacion + financiero. | dashboard, ranking, awards, finance. | Reportes. | `fetchReportBundle`. |
| `DashboardBundle` | Reportes mas datos extra para dashboard. | Reportes + proyecciones + ventas. | todo lo de `ReportBundle`, top vendido, proyecciones. | Dashboard. | `fetchDashboardBundle`. |
| `ApiCatalog` | Paquete de catalogos iniciales. | Multiples catalogos API. | ediciones, peliculas, asistentes, personas, salas, generos, eventos, etc. | `Shell`. | `fetchCatalog`. |

## Widgets compartidos

| Widget | Que hace | Parametros principales | Donde se usa | Cuando reutilizarlo |
| --- | --- | --- | --- | --- |
| `SeatMap` | Dibuja la grilla de asientos y bloquea ocupados. | `selected`, `occupied`, `onToggle`, `capacity` | Taquilla. | Cualquier seleccion de asientos. |
| `ScreenPainter` | Dibuja la pantalla del cine dentro de `SeatMap`. | Canvas interno. | `SeatMap`. | Solo si cambia el dibujo de sala. |
| `GenericQr` | Muestra un QR visual generico para recibos. | `data`, `size` | Taquilla y eventos. | Recibos o codigos visuales simples. |
| `Header` | Encabezado de seccion con titulo, subtitulo y trailing. | `title`, `subtitle`, `trailing` | Casi todas las pantallas. | Inicio de pantallas o paneles grandes. |
| `ResponsiveGrid` | Grid adaptable segun ancho. | `children`, `minItemWidth`, `gap` | Dashboard, peliculas, reportes. | Listas de cards responsivas. |
| `CardBox` | Contenedor tipo tarjeta con titulo opcional. | `title`, `subtitle`, `child`, `actions` | Formularios, listas, estados. | Para paneles visuales consistentes. |
| `StatCard` | Tarjeta de metrica. | `label`, `value`, `icon`, `color` | Dashboard/reportes. | Numeros destacados. |
| `BadgeIcon` | Icono con fondo decorativo. | `icon`, `color`, `size` | Login, sidebar, cards. | Iconos protagonistas. |
| `Pill` | Etiqueta compacta. | texto/color. | Sidebar y varias cards. | Estados o etiquetas pequenas. |
| `StatusChip` | Chip de estado. | `label`, `color`, icono opcional. | Topbar, eventos, reportes. | Estados visibles. |
| `InfoBox` | Caja informativa. | titulo, valor, icono/color. | Sidebar y pantallas. | Resumen corto con icono. |
| `ProgressRow` | Fila con barra de progreso. | label, value, percent. | Dashboard/reportes. | Rankings y porcentajes. |
| `EmptyState` | Estado vacio. | icono, titulo, mensaje. | Listas sin datos. | Cuando un catalogo no tiene elementos. |
| `StepperPills` | Indicador de pasos. | pasos, indice actual. | Taquilla. | Flujos paso a paso. |
| `MovieCard` | Tarjeta visual de pelicula. | `movie`, `selected`, `onTap` | Taquilla y peliculas. | Mostrar peliculas de forma uniforme. |
| `ActionCard` | Card clickeable para acciones. | icono, titulo, descripcion, onTap. | Pantallas administrativas. | Accesos rapidos. |
| `BackLine` | Linea de volver/navegacion interna. | texto y callback. | Flujos internos. | Para volver de una seleccion. |
| `RemovableChip` | Chip con opcion de eliminar. | label, onRemove. | Generos, categorias, listas seleccionadas. | Selecciones removibles. |
| `CategoryPickerDialog` | Modal para elegir/agregar categorias. | categorias, seleccion actual. | Ediciones. | Seleccion multiple de categorias. |
| `GenrePickerDialog` | Modal para elegir/agregar generos. | generos, seleccion actual. | Peliculas. | Seleccion multiple de generos. |
| `DirectorFormDialog` | Modal para buscar o crear director. | personas/directores. | Peliculas. | Director o personal cinematografico. |
| `JuryFormDialog` | Modal para crear jurado. | datos de jurado. | Ediciones. | Alta de jurados. |
| `Legend` | Leyenda visual de colores. | items. | Agenda. | Explicar colores en una vista. |
| `AlertBanner` | Mensaje de exito/error/informacion. | mensaje, color, onClose. | Shell y pantallas. | Mostrar resultado de operaciones. |
| `SelectLine` | Fila seleccionable compacta. | label, subtitle, selected, onTap. | Dialogos/listas. | Opciones seleccionables. |

## Flujos importantes

### Flujo de compra de entrada

1. El cajero entra a `TaquillaPage` en modo entrada.
2. Selecciona una pelicula desde `MovieCard`.
3. Selecciona una funcion (`Session`).
4. Selecciona un asiento en `SeatMap`; los ocupados vienen de `GET /api/entradas-individuales`.
5. Llena o selecciona datos de persona.
6. `resolveAttendee` busca persona/asistente y crea lo que falte.
7. Selecciona tarifa y metodo de pago.
8. Si la tarifa es de acreditado, se revisa acreditacion/abono permitido.
9. `_confirmPurchase` llama a `p1ComprarEntrada`.
10. El backend responde compra, entrada, factura y monto.
11. La UI muestra recibo y `GenericQr`.

### Flujo de venta de abono

1. El cajero cambia `SaleMode` a abono.
2. Llena datos de persona.
3. Selecciona tipo de abono desde `SubscriptionType`.
4. `resolveAttendee` resuelve persona/asistente.
5. `_confirmSubscriptionPurchase` llama a `venderAbono`.
6. Se muestra recibo con codigo de abono y factura.

### Flujo de venta de entrada para evento

1. El cajero abre `EventTicketPage`.
2. Selecciona un `FestivalEvent`.
3. Llena datos de persona/asistente.
4. El formulario valida datos minimos.
5. `resolveAttendee` resuelve persona/asistente.
6. `venderEntradaEvento` revisa aforo vendido, crea compra, entrada y factura.
7. La pantalla muestra confirmacion y QR.

### Flujo de creacion de pelicula

1. El admin abre `AdminMoviesPage`.
2. Llena datos base: titulo, anio, duracion, pais, sinopsis, clasificacion, formato y poster.
3. Selecciona generos con `GenrePickerDialog`; puede agregar uno nuevo.
4. Selecciona o crea director con `DirectorFormDialog`.
5. `createMovieForEdition` valida duplicados por titulo normalizado.
6. Crea pelicula en `/api/peliculas`.
7. Crea relacion con edicion en `/api/pelicula-ediciones`.
8. Crea o vincula generos.
9. Resuelve persona/personal cinematografico/rol director.
10. Crea participacion cinematografica.
11. La pelicula se inserta en la lista local para verla en pantalla.

### Flujo de creacion de evento

1. El admin abre `AdminEventsPage`.
2. Selecciona edicion y sala.
3. Llena nombre, tipo, descripcion, aforo, costo, fecha, hora y duracion.
4. `edition_rules.dart` bloquea ediciones finalizadas, canceladas o fuera de rango.
5. `_createEvent` arma `EventDraft`.
6. `createFestivalEvent` envia `POST /api/agenda/eventos`.
7. El evento creado vuelve como `FestivalEvent` y se muestra en la lista.

### Flujo de creacion de edicion

1. El admin abre `AdminEditionsPage`.
2. Llena nombre, fechas, estado y sede.
3. Selecciona peliculas, categorias y jurados.
4. Opcionalmente elige patrocinador existente o registra uno nuevo.
5. `createFestivalEdition` crea la edicion.
6. Crea relacion sede-edicion con clave compuesta.
7. Crea relaciones pelicula-edicion.
8. Crea categorias y relacion categoria-jurados.
9. Si corresponde, crea patrocinador y patrocinio.

### Flujo de reportes

1. La pantalla recibe una `FestivalEdition`.
2. `ReportesPage` llama a `fetchReportBundle`.
3. El gateway consulta dashboard, ranking, premiacion y financiero.
4. Los mappers convierten JSON a modelos.
5. La UI muestra tarjetas, rankings y resumen financiero.

## Advertencias tecnicas

- No cambiar endpoints sin revisar el backend ASP.NET Core.
- No cambiar payloads JSON sin revisar controladores y DTOs del backend.
- No romper la relacion Persona -> Asistente: muchas compras dependen de esa resolucion.
- No duplicar logica que ya maneja SQL o el backend.
- No agregar datos fallback falsos para "hacer pasar" pantallas.
- No cambiar nombres publicos de clases o metodos sin actualizar todos los usos.
- No mover clases privadas con `_` a librerias separadas con imports normales sin renombrarlas.
- No pasar `null` a callbacks no nullable.
- No modificar visual sin autorizacion: `theme.dart` y `common_widgets.dart` afectan muchas pantallas.
- No cambiar venta de entradas, abonos o eventos sin probar contra backend.
- No relajar validaciones de aforo, acreditacion, asiento o edicion sin una razon de negocio.
- Si se toca algun `.dart`, ejecutar `flutter analyze`.

## Idea clave para la defensa

El frontend guia al usuario y organiza la experiencia, pero la verdad del negocio esta en el backend y en la base de datos. La app Flutter no decide sola ventas, reportes o relaciones importantes: prepara datos, llama endpoints y muestra respuestas. Por eso la modularizacion ayuda a defender el proyecto: cada capa tiene un lugar claro y se puede explicar donde vive cada responsabilidad.

Para estudiar el proyecto rapido:

1. Empieza por `lib/main.dart` para ver las partes.
2. Luego mira `lib/app/shell.dart` para entender navegacion y catalogos.
3. Revisa una pantalla en `lib/features/`.
4. Sigue sus llamadas a `lib/data/database_gateway.dart`.
5. Consulta los modelos en `lib/domain/models/`.
6. Si algo es visual reutilizable, estara en `lib/shared/widgets/`.
