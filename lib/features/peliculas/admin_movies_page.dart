part of '../../main.dart';

class AdminMoviesPage extends StatefulWidget {

  const AdminMoviesPage({

    super.key,

    required this.movies,

    required this.editionId,

    required this.genres,

    required this.directors,

    required this.people,

    required this.onAdd,

    required this.onDelete,

  });



  final List<Movie> movies;

  final String editionId;

  final List<GenreOption> genres;

  final List<DirectorOption> directors;

  final List<PersonOption> people;

  final ValueChanged<Movie> onAdd;

  final ValueChanged<Movie> onDelete;



  @override

  State<AdminMoviesPage> createState() => _AdminMoviesPageState();

}



class _AdminMoviesPageState extends State<AdminMoviesPage> {

  final title = TextEditingController();

  final productionYear = TextEditingController(text: DateTime.now().year.toString());

  final duration = TextEditingController(text: '100');

  final rating = TextEditingController(text: '+13');

  final country = TextEditingController(text: 'Bolivia');

  final synopsis = TextEditingController();

  final poster = TextEditingController(text: randomPosterUrls.first);

  late List<GenreOption> availableGenres;

  late List<DirectorOption> availableDirectors;

  final selectedGenres = <GenreOption>[];

  String selectedDirectorId = '';

  String selectedFormat = projectionFormatOptions.first;

  int posterIndex = 0;

  String? message;

  bool messageIsError = false;

  bool saving = false;



  @override

  void initState() {

    super.initState();

    availableGenres = [...widget.genres];

    availableDirectors = [...widget.directors];

    if (availableGenres.isNotEmpty) selectedGenres.add(availableGenres.first);

    selectedDirectorId =

        availableDirectors.isEmpty ? '' : availableDirectors.first.id;

  }



  @override

  void didUpdateWidget(covariant AdminMoviesPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.genres != widget.genres) {

      availableGenres = mergeGenreOptions(availableGenres, widget.genres);

    }

    if (oldWidget.directors != widget.directors) {

      availableDirectors = mergeDirectorOptions(

        availableDirectors,

        widget.directors,

      );

      if (selectedDirectorId.isEmpty && availableDirectors.isNotEmpty) {

        selectedDirectorId = availableDirectors.first.id;

      }

    }

  }



  @override

  void dispose() {

    title.dispose();

    productionYear.dispose();

    duration.dispose();

    rating.dispose();

    country.dispose();

    synopsis.dispose();

    poster.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Header(

          'Gestion de peliculas',

          'Administrador: agrega estrenos, sube portada por URL y borra peliculas de cartelera',

        ),

        const SizedBox(height: 16),

        if (message != null) ...[

          AlertBanner(

            message!,

            messageIsError ? red : green,

            onClose: () => setState(() => message = null),

          ),

          const SizedBox(height: 12),

        ],

        LayoutBuilder(

          builder: (context, c) {

            final narrow = c.maxWidth < 860;

            if (narrow) {

              return Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _form(),

                  const SizedBox(height: 16),

                  _list(),

                ],

              );

            }

            return Flex(

              direction: Axis.horizontal,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Expanded(flex: 1, child: _form()),

                const SizedBox(width: 16),

                Expanded(flex: 2, child: _list()),

              ],

            );

          },

        ),

      ],

    );

  }



  Widget _form() {

    return CardBox(

      title: 'Nueva pelicula / estreno',

      subtitle: 'Completa los datos que se veran en cartelera',

      child: Column(

        children: [

          ClipRRect(

            borderRadius: BorderRadius.circular(10),

            child: AspectRatio(

              aspectRatio: 16 / 10,

              child: Image.network(

                poster.text,

                key: ValueKey(poster.text),

                fit: BoxFit.cover,

                errorBuilder: (_, _, _) => Container(

                  color: surface2,

                  child: const Center(

                    child: Icon(

                      Icons.broken_image_outlined,

                      color: red,

                      size: 44,

                    ),

                  ),

                ),

              ),

            ),

          ),

          const SizedBox(height: 12),

          TextField(

            controller: title,

            decoration: const InputDecoration(

              labelText: 'Nombre de la pelicula',

            ),

          ),

          const SizedBox(height: 10),

          TextField(

            controller: poster,

            onChanged: (_) => setState(() {}),

            decoration: const InputDecoration(

              labelText: 'Portada',

              helperText: 'Pega una URL de imagen o usa portada random',

            ),

          ),

          const SizedBox(height: 10),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: [

              SizedBox(width: 360, child: _genrePicker()),

              SizedBox(

                width: 150,

                child: TextField(

                  controller: productionYear,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(

                    labelText: 'Anio produccion',

                  ),

                ),

              ),

              SizedBox(

                width: 120,

                child: TextField(

                  controller: duration,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(labelText: 'Duracion'),

                ),

              ),

              SizedBox(

                width: 110,

                child: TextField(

                  controller: rating,

                  decoration: const InputDecoration(labelText: 'Clasif.'),

                ),

              ),

              SizedBox(

                width: 145,

                child: TextField(

                  controller: country,

                  decoration: const InputDecoration(labelText: 'Pais'),

                ),

              ),

              SizedBox(width: 260, child: _directorPicker()),

              SizedBox(

                width: 190,

                child: DropdownButtonFormField<String>(

                  initialValue: selectedFormat,

                  isExpanded: true,

                  decoration:

                      const InputDecoration(labelText: 'Formato proyeccion'),

                  items: projectionFormatOptions

                      .map(

                        (item) => DropdownMenuItem(

                          value: item,

                          child: Text(item),

                        ),

                      )

                      .toList(),

                  onChanged: (value) => setState(

                    () => selectedFormat = value ?? selectedFormat,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 10),

          TextField(

            controller: synopsis,

            minLines: 3,

            maxLines: 4,

            decoration: const InputDecoration(labelText: 'Sinopsis'),

          ),

          const SizedBox(height: 14),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: [

              OutlinedButton.icon(

                onPressed: _randomPoster,

                icon: const Icon(Icons.shuffle),

                label: const Text('Portada random'),

              ),

              FilledButton.icon(

                onPressed: saving ? null : _createMovie,

                icon: saving

                    ? const SizedBox(

                        width: 18,

                        height: 18,

                        child: CircularProgressIndicator(strokeWidth: 2),

                      )

                    : const Icon(Icons.add),

                label: Text(saving ? 'Guardando...' : 'Crear pelicula'),

              ),

            ],

          ),

        ],

      ),

    );

  }



  Widget _genrePicker() => Container(

    width: double.infinity,

    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(

      color: surface,

      borderRadius: BorderRadius.circular(radiusMd),

      border: Border.all(color: line),

    ),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(

          children: [

            const Expanded(

              child: Text(

                'Generos',

                style: TextStyle(color: burgundy, fontWeight: FontWeight.w800),

              ),

            ),

            IconButton.filledTonal(

              tooltip: 'Agregar genero',

              onPressed: _openGenreDialog,

              icon: const Icon(Icons.add),

            ),

          ],

        ),

        const SizedBox(height: 8),

        Wrap(

          spacing: 8,

          runSpacing: 8,

          children: [

            if (selectedGenres.isEmpty)

              const Text(

                'Agrega al menos un genero.',

                style: TextStyle(color: muted, fontSize: 12),

              ),

            ...selectedGenres.map(

              (genre) => RemovableChip(

                label: genre.name,

                onDeleted: () => setState(() => selectedGenres.remove(genre)),

              ),

            ),

          ],

        ),

      ],

    ),

  );



  Widget _directorPicker() {

    final selectedExists =

        availableDirectors.any((item) => item.id == selectedDirectorId);

    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Expanded(

          child: DropdownButtonFormField<String>(

            initialValue: selectedExists ? selectedDirectorId : null,

            isExpanded: true,

            decoration: const InputDecoration(labelText: 'Director'),

            items: availableDirectors

                .map(

                  (item) => DropdownMenuItem(

                    value: item.id,

                    child: Text(item.name),

                  ),

                )

                .toList(),

            onChanged: (value) => setState(

              () => selectedDirectorId = value ?? selectedDirectorId,

            ),

          ),

        ),

        const SizedBox(width: 8),

        IconButton.filledTonal(

          tooltip: 'Registrar director',

          onPressed: _openDirectorDialog,

          icon: const Icon(Icons.person_add_alt_1_outlined),

        ),

      ],

    );

  }



  Future<void> _openGenreDialog() async {

    final option = await showDialog<GenreOption>(

      context: context,

      builder: (context) => GenrePickerDialog(options: availableGenres),

    );

    if (option == null) return;

    final alreadySelected = selectedGenres.any(

      (item) => normalizeText(item.name) == normalizeText(option.name),

    );

    if (alreadySelected) {

      setState(() {

        message = 'Ese genero ya esta seleccionado.';

        messageIsError = true;

      });

      return;

    }

    setState(() {

      availableGenres = mergeGenreOptions(availableGenres, [option]);

      selectedGenres.add(option);

      message = null;

      messageIsError = false;

    });

  }



  Future<void> _openDirectorDialog() async {

    final option = await showDialog<DirectorOption>(

      context: context,

      builder: (context) => DirectorFormDialog(people: widget.people),

    );

    if (option == null) return;

    setState(() {

      availableDirectors = mergeDirectorOptions(availableDirectors, [option]);

      selectedDirectorId = availableDirectors

          .firstWhere(

            (item) => normalizeText(item.name) == normalizeText(option.name),

            orElse: () => option,

          )

          .id;

      message = null;

      messageIsError = false;

    });

  }



  Widget _list() {

    return CardBox(

      title: 'Cartelera actual',

      subtitle: 'Estas peliculas aparecen en Taquilla para el Cajero',

      child: Column(

        children: widget.movies.map((movie) {

          return Padding(

            padding: const EdgeInsets.only(bottom: 12),

            child: Container(

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color: surface2,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: line),

              ),

              child: Row(

                children: [

                  ClipRRect(

                    borderRadius: BorderRadius.circular(8),

                    child: Image.network(

                      movie.posterUrl,

                      width: 92,

                      height: 58,

                      fit: BoxFit.cover,

                      errorBuilder: (_, _, _) => Container(

                        width: 92,

                        height: 58,

                        color: bg,

                        child: const Icon(Icons.movie_outlined, color: red),

                      ),

                    ),

                  ),

                  const SizedBox(width: 12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          movie.title,

                          style: const TextStyle(

                            color: text,

                            fontWeight: FontWeight.w800,

                          ),

                        ),

                        Text(

                          '${movie.genre} - ${movie.duration} min - ${movie.country}',

                          style: const TextStyle(color: muted, fontSize: 12),

                        ),

                        if (movie.director.isNotEmpty)

                          Text(

                            'Director: ${movie.director}',

                            style: const TextStyle(color: muted, fontSize: 12),

                          ),

                      ],

                    ),

                  ),

                  IconButton(

                    tooltip: 'Borrar de cartelera',

                    onPressed: widget.movies.length == 1

                        ? null

                        : () => _confirmDelete(movie),

                    icon: const Icon(Icons.delete_outline, color: red),

                  ),

                ],

              ),

            ),

          );

        }).toList(),

      ),

    );

  }



  void _randomPoster() {

    setState(() {

      posterIndex = (posterIndex + 1) % randomPosterUrls.length;

      poster.text = randomPosterUrls[posterIndex];

    });

  }



  Future<void> _createMovie() async {

    final cleanTitle = title.text.trim();

    if (cleanTitle.isEmpty) {

      setState(() {

        message = 'Escribe el nombre de la pelicula antes de crearla.';

        messageIsError = true;

      });

      return;

    }

    if (selectedGenres.isEmpty) {

      setState(() {

        message = 'Agrega al menos un genero para la pelicula.';

        messageIsError = true;

      });

      return;

    }



    final minutes = int.tryParse(duration.text.trim()) ?? 100;

    setState(() {

      saving = true;

      message = 'Guardando pelicula en el backend...';

      messageIsError = false;

    });



    try {

      final selectedDirector = availableDirectors.firstWhere(

        (item) => item.id == selectedDirectorId,

        orElse: () => const DirectorOption('', 'Sin director registrado'),

      );

      final newMovie = await DatabaseGateway.createMovieForEdition(

        MovieDraft(

          title: cleanTitle,

          productionYear:

              int.tryParse(productionYear.text.trim()) ?? DateTime.now().year,

          duration: minutes,

          rating: rating.text.trim().isEmpty ? '+13' : rating.text.trim(),

          country: country.text.trim().isEmpty ? 'Bolivia' : country.text.trim(),

          synopsis: synopsis.text.trim().isEmpty

              ? 'Estreno agregado por administracion para la cartelera del festival.'

              : synopsis.text.trim(),

          posterUrl:

              poster.text.trim().isEmpty ? randomPosterUrls.first : poster.text.trim(),

          format: selectedFormat,

          editionId: widget.editionId,

          genres: selectedGenres,

          director: selectedDirector,

        ),

      );



      widget.onAdd(newMovie);

      setState(() {

        saving = false;

        message =

            '"$cleanTitle" fue agregada a cartelera y guardada en la base de datos.';

        messageIsError = false;

        title.clear();

        synopsis.clear();

        selectedGenres

          ..clear()

          ..addAll(availableGenres.isEmpty ? const [] : [availableGenres.first]);

        selectedDirectorId =

            availableDirectors.isEmpty ? '' : availableDirectors.first.id;

        selectedFormat = projectionFormatOptions.first;

        _randomPoster();

      });

    } on DatabaseException catch (error) {

      setState(() {

        saving = false;

        message = error.friendlyMessage;

        messageIsError = true;

      });

    }

  }



  Future<void> _confirmDelete(Movie movie) async {

    final confirmed = await showDialog<bool>(

      context: context,

      builder: (context) => AlertDialog(

        title: const Text('Borrar pelicula'),

        content: Text(

          'Estas seguro de borrar "${movie.title}" de la cartelera?',

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context, false),

            child: const Text('Cancelar'),

          ),

          FilledButton.icon(

            onPressed: () => Navigator.pop(context, true),

            icon: const Icon(Icons.delete_outline),

            label: const Text('Borrar'),

          ),

        ],

      ),

    );



    if (confirmed != true) return;

    widget.onDelete(movie);

    setState(() {

      message = '"${movie.title}" fue retirada de cartelera.';

    });

  }

}

