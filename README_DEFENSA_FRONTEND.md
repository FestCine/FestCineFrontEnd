# Defensa del frontend FestCine

## Objetivo

El frontend de FestCine es el cliente visual de la aplicacion. No modifica la base de datos directamente ni ejecuta SQL: captura datos, muestra catalogos reales y llama al backend ASP.NET Core para que las reglas de negocio se apliquen desde procedimientos, restricciones y relaciones de la base.

## Conexion

La URL del backend se define con `API_BASE_URL`. Por defecto usa:

```text
http://localhost:5075
```

La conexion a SQL Server, incluyendo el servidor `JULIOPC`, queda configurada en el backend. El frontend solo consume endpoints HTTP.

## Edicion activa y ediciones pasadas

Al iniciar, el frontend consulta:

```text
GET /api/ediciones
```

Ordena primero la edicion con estado `Actual` y la muestra como festival activo. En el dashboard existe un selector de ediciones para consultar ediciones pasadas; al cambiarlo, la cartelera, asistentes, salas, agenda, dashboard y reportes se recalculan con el `IdEdicion` seleccionado.

## Dashboard y reportes reales

El dashboard de admin y cajero ya no usa numeros de ejemplo. Consume:

```text
GET /api/dashboard/{idEdicion}
GET /api/reportes/ranking/{idEdicion}
GET /api/reportes/premiacion/{idEdicion}
GET /api/reportes/financiero/{idEdicion}
GET /api/catalogos/proyecciones/{idEdicion}
GET /api/entradas-individuales
```

Con esos datos muestra peliculas, proyecciones, asistentes, entradas vendidas, abonos, recaudacion, peliculas mas vistas, peliculas mas vendidas, premiacion y resumen financiero.

## Taquilla y asientos

La taquilla carga peliculas, proyecciones, tarifas, asistentes, personas y entradas vendidas desde el backend. Para marcar asientos ocupados consulta `GET /api/entradas-individuales`, agrupa por `IdProyeccion` y convierte `NroAsiento` al asiento visual correspondiente. La pantalla bloquea esos asientos para que no se puedan seleccionar.

## Asistentes y duplicados

En la compra ya no se elige un asistente desde una lista fija. El cajero llena nombre, apellido, correo y telefono. El frontend busca coincidencias en:

```text
GET /api/personas
GET /api/asistentes
```

La comparacion normaliza mayusculas, minusculas, espacios y tildes simples. Tambien compara correo y telefono. Si la persona existe, reutiliza sus datos; si no existe, crea la persona y luego crea el asistente para la edicion seleccionada.

## Compra, abonos y factura

En Taquilla el cajero puede elegir entre vender una entrada individual o vender un abono.

Para entrada individual, el frontend llama:

```text
POST /api/taquilla/comprar-entrada
```

Envia asistente, proyeccion, tarifa, metodo de pago, NIT/CI, nombre de compra y asiento. La factura visual muestra codigo de entrada, numero de factura, metodo de pago, monto y un QR generico generado en pantalla.

Si la tarifa seleccionada es `Acreditado`, el frontend consulta los abonos activos del asistente y valida si el abono elegido esta permitido para la proyeccion usando:

```text
GET /api/abonos-crud
GET /api/relaciones/abono-proyecciones
```

Cuando el asistente tiene mas de un abono, se muestra una lista desplegable para seleccionar cual se usara. Si el par `IdAbono + IdProyeccion` no existe en `AbonoProyeccion`, la compra se bloquea antes de llamar a la taquilla.

Para abonos, el frontend consulta:

```text
GET /api/tipo-abonos
```

Luego vende el abono con:

```text
POST /api/abonos/vender
```

Los tipos soportados salen de la base de datos, por ejemplo `Abono Fin de Semana`, `Abono Total`, `Abono Prensa`, `Abono VIP` y `Abono Jurado`.

## Ediciones con clave compuesta

Para la relacion sede-edicion se respeta el cambio del backend y la base: ya no se envia `IdSedeEdicion`. El frontend crea la relacion con:

```text
POST /api/sede-ediciones
```

usando solo `IdSede` e `IdEdicion`, que forman la clave compuesta. Tambien crea peliculas de la edicion, categorias y jurados mediante:

```text
POST /api/pelicula-ediciones
POST /api/categorias-competicion
POST /api/relaciones/categoria-jurados
```

Ademas, al crear una edicion se puede seleccionar un patrocinador existente o registrar uno nuevo. El frontend usa:

```text
GET /api/patrocinadores
POST /api/patrocinadores
POST /api/patrocinios
```

El patrocinio queda asociado a la edicion creada con tipo de aportacion, monto y descripcion.

## Mensajes de error

Cuando el backend responde errores con `mensaje`, `message` o `error`, el frontend los muestra en la pantalla correspondiente. Asi los errores de procedimientos, validaciones, claves o reglas de negocio llegan al usuario sin mostrar detalles internos como comandos SQL.

## Peliculas

Las tarjetas de peliculas muestran informacion relevante: titulo, pais, generos, duracion, clasificacion, sinopsis, director y formato si existen en los catalogos relacionados.

El formulario de creacion de pelicula cubre los campos de la entidad `Pelicula`:

```text
IdPelicula, Titulo, AnioProduccion, Duracion, PaisOrigen, Sinopsis, ClasEdad, FormatoProyeccion
```

`IdPelicula` se genera desde el frontend segun el catalogo actual. Los demas campos se capturan en el formulario. Ademas, el formulario captura datos de relacion: generos, director y edicion.

Para crear una pelicula/estreno se usan:

```text
POST /api/peliculas
POST /api/pelicula-ediciones
GET /api/catalogos/generos
POST /api/generos
GET /api/relaciones/pelicula-generos
POST /api/relaciones/pelicula-generos
GET /api/personal-cinematografico
GET /api/roles-cinematograficos
GET /api/participaciones-pelicula
POST /api/participaciones-pelicula
```

Los generos se manejan como chips: se puede seleccionar un genero existente o escribir uno nuevo. Si no existe, se crea con `/api/generos` y luego se relaciona con la pelicula usando `/api/relaciones/pelicula-generos`.

## Categorias y jurados

En Ediciones, las categorias ya no se escriben como texto libre multilinea. Se seleccionan desde el catalogo o se agregan con un boton `+`. Al crear la edicion, cada categoria seleccionada se crea para la nueva edicion con:

```text
POST /api/categorias-competicion
```

Los jurados pueden seleccionarse desde los existentes o crearse desde el frontend. Crear un jurado genera primero la `Persona` y luego el registro `Jurado`:

```text
POST /api/personas
POST /api/jurados
POST /api/relaciones/categoria-jurados
```

Los campos usados vienen del SQL `FestCine_corregido_asociativas_puras.sql`, ubicado en:

```text
D:\Personal\Universidad\Semestre5\Base de Datos\Proyecto
```

## Interfaz visual

La interfaz usa una paleta solida inspirada en las referencias visuales: rojo cine como color primario, azul noche para navegacion, gris azulado y vino como secundarios, y durazno para superficies destacadas. La barra lateral tiene color propio, el login comparte la identidad visual y las tarjetas usan fondos solidos sin degradados. Tambien se corrigio el panel lateral para que el texto de la edicion seleccionada no sobrepase sus dimensiones.

Los mensajes informativos de acciones normales se redujeron para no llenar la pantalla con avisos innecesarios. Los errores del backend se siguen mostrando porque son necesarios para explicar validaciones y excepciones.

## Idea clave para la defensa

El frontend guia al usuario, pero la verdad de negocio esta en el backend y en la base de datos. Los dashboards, reportes, asientos ocupados, compras, asistentes y ediciones salen de datos reales; la interfaz solo los organiza para que sean faciles de usar y defender.
