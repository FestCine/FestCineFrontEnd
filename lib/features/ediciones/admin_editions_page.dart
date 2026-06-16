part of '../../main.dart';

class AdminEditionsPage extends StatefulWidget {

  const AdminEditionsPage({

    super.key,

    required this.venues,

    required this.movies,

    required this.categories,

    required this.jurors,

    required this.sponsors,

    required this.onJurorAdd,

  });



  final List<VenueOption> venues;

  final List<MovieOption> movies;

  final List<CategoryOption> categories;

  final List<JuryMember> jurors;

  final List<SponsorOption> sponsors;

  final ValueChanged<JuryMember> onJurorAdd;



  @override

  State<AdminEditionsPage> createState() => _AdminEditionsPageState();

}



class _AdminEditionsPageState extends State<AdminEditionsPage> {

  final name = TextEditingController(text: 'FestCine 2027');

  final start = TextEditingController(text: '2027-08-07');

  final end = TextEditingController(text: '2027-08-15');

  final sponsorName = TextEditingController();

  final sponsorPhone = TextEditingController();

  final sponsorEmail = TextEditingController();

  final sponsorAmount = TextEditingController(text: '10000');

  final sponsorDescription = TextEditingController(

    text: 'Aporte para la nueva edicion del festival.',

  );

  String status = 'Planificada';

  String? venueId;

  bool includeSponsor = true;

  bool createSponsor = false;

  String? sponsorId;

  String sponsorContributionType = 'Economica';

  late List<CategoryOption> availableCategories;

  late List<JuryMember> availableJurors;

  final selectedMovies = <String>{};

  final selectedCategories = <CategoryOption>[];

  final selectedJurors = <String>{};

  String? message;

  bool saving = false;



  @override

  void initState() {

    super.initState();

    venueId = widget.venues.isEmpty ? null : widget.venues.first.id;

    sponsorId = widget.sponsors.isEmpty ? null : widget.sponsors.first.id;

    availableCategories = [...widget.categories];

    availableJurors = [...widget.jurors];

    selectedMovies.addAll(widget.movies.take(3).map((movie) => movie.id));

    selectedCategories.addAll(availableCategories.take(3));

    selectedJurors.addAll(availableJurors.take(2).map((juror) => juror.id));

  }



  @override

  void didUpdateWidget(covariant AdminEditionsPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.categories != widget.categories) {

      availableCategories = mergeCategoryOptions(

        availableCategories,

        widget.categories,

      );

    }

    if (oldWidget.jurors != widget.jurors) {

      availableJurors = mergeJuryMembers(availableJurors, widget.jurors);

    }

  }



  @override

  void dispose() {

    name.dispose();

    start.dispose();

    end.dispose();

    sponsorName.dispose();

    sponsorPhone.dispose();

    sponsorEmail.dispose();

    sponsorAmount.dispose();

    sponsorDescription.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Header(

          'Ediciones del festival',

          'Registro integral: sede, peliculas, categorias y jurados',

        ),

        const SizedBox(height: 16),

        if (message != null) ...[

          AlertBanner(

            message!,

            message!.startsWith('Error') ? red : green,

            onClose: () => setState(() => message = null),

          ),

          const SizedBox(height: 12),

        ],

        LayoutBuilder(

          builder: (context, c) {

            final narrow = c.maxWidth < 900;

            if (narrow) {

              return Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _editionForm(),

                  const SizedBox(height: 16),

                  _selectionPanel(),

                ],

              );

            }

            return Flex(

              direction: Axis.horizontal,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Expanded(flex: 1, child: _editionForm()),

                const SizedBox(width: 16),

                Expanded(flex: 1, child: _selectionPanel()),

              ],

            );

          },

        ),

      ],

    );

  }



  Widget _editionForm() => CardBox(

    title: 'Nueva edicion',

    subtitle: 'Datos principales y sede habilitada',

    child: Column(

      children: [

        TextField(

          controller: name,

          decoration: const InputDecoration(labelText: 'Nombre de la edicion'),

        ),

        const SizedBox(height: 10),

        Wrap(

          spacing: 10,

          runSpacing: 10,

          children: [

            SizedBox(

              width: 170,

              child: TextField(

                controller: start,

                decoration: const InputDecoration(labelText: 'Fecha inicio'),

              ),

            ),

            SizedBox(

              width: 170,

              child: TextField(

                controller: end,

                decoration: const InputDecoration(labelText: 'Fecha fin'),

              ),

            ),

            SizedBox(

              width: 190,

              child: DropdownButtonFormField<String>(

                initialValue: status,

                decoration: const InputDecoration(labelText: 'Estado'),

                items: const ['Planificada', 'Actual', 'Finalizada', 'Cancelada']

                    .map(

                      (item) => DropdownMenuItem(

                        value: item,

                        child: Text(item),

                      ),

                    )

                    .toList(),

                onChanged: (value) => setState(() => status = value ?? status),

              ),

            ),

          ],

        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(

          initialValue: venueId,

          decoration: const InputDecoration(labelText: 'Sede principal'),

          items: widget.venues

              .map(

                (venue) => DropdownMenuItem(

                  value: venue.id,

                  child: Text(venue.name),

                ),

              )

              .toList(),

          onChanged: (value) => setState(() => venueId = value),

        ),

        const SizedBox(height: 10),

        _categoryPicker(),

        const SizedBox(height: 12),

        _sponsorForm(),

        const SizedBox(height: 14),

        FilledButton.icon(

          onPressed: saving ? null : _saveEdition,

          icon: saving

              ? const SizedBox(

                  width: 18,

                  height: 18,

                  child: CircularProgressIndicator(strokeWidth: 2),

                )

              : const Icon(Icons.save_outlined),

          label: Text(saving ? 'Registrando...' : 'Registrar edicion'),

        ),

      ],

    ),

  );



  Widget _categoryPicker() => Container(

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

                'Categorias de competicion',

                style: TextStyle(color: burgundy, fontWeight: FontWeight.w800),

              ),

            ),

            IconButton.filledTonal(

              tooltip: 'Agregar categoria',

              onPressed: _openCategoryDialog,

              icon: const Icon(Icons.add),

            ),

          ],

        ),

        const SizedBox(height: 8),

        Wrap(

          spacing: 8,

          runSpacing: 8,

          children: [

            if (selectedCategories.isEmpty)

              const Text(

                'Agrega al menos una categoria.',

                style: TextStyle(color: muted, fontSize: 12),

              ),

            ...selectedCategories.map(

              (category) => RemovableChip(

                label: category.name,

                onDeleted: () =>

                    setState(() => selectedCategories.remove(category)),

              ),

            ),

          ],

        ),

      ],

    ),

  );



  Future<void> _openCategoryDialog() async {

    final option = await showDialog<CategoryOption>(

      context: context,

      builder: (context) => CategoryPickerDialog(options: availableCategories),

    );

    if (option == null) return;

    final alreadySelected = selectedCategories.any(

      (item) => normalizeText(item.name) == normalizeText(option.name),

    );

    if (alreadySelected) {

      setState(() => message = 'Error: esa categoria ya esta seleccionada.');

      return;

    }

    setState(() {

      availableCategories = mergeCategoryOptions(availableCategories, [option]);

      selectedCategories.add(option);

      message = null;

    });

  }



  Widget _sponsorForm() => Container(

    width: double.infinity,

    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(

      color: surface2,

      borderRadius: BorderRadius.circular(12),

      border: Border.all(color: gold),

    ),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        SwitchListTile(

          contentPadding: EdgeInsets.zero,

          value: includeSponsor,

          onChanged: (value) => setState(() => includeSponsor = value),

          title: const Text('Asignar patrocinador'),

          subtitle: const Text('Selecciona uno existente o registra uno nuevo'),

        ),

        if (includeSponsor) ...[

          SegmentedButton<bool>(

            segments: const [

              ButtonSegment(

                value: false,

                label: Text('Existente'),

                icon: Icon(Icons.business_outlined),

              ),

              ButtonSegment(

                value: true,

                label: Text('Nuevo'),

                icon: Icon(Icons.add_business_outlined),

              ),

            ],

            selected: {createSponsor},

            onSelectionChanged: (value) =>

                setState(() => createSponsor = value.first),

          ),

          const SizedBox(height: 10),

          if (!createSponsor)

            DropdownButtonFormField<String>(

              initialValue: sponsorId,

              isExpanded: true,

              decoration: const InputDecoration(

                labelText: 'Patrocinador existente',

                border: OutlineInputBorder(),

              ),

              items: widget.sponsors

                  .map(

                    (sponsor) => DropdownMenuItem(

                      value: sponsor.id,

                      child: Text(sponsor.name),

                    ),

                  )

                  .toList(),

              onChanged: (value) => setState(() => sponsorId = value),

            )

          else

            Wrap(

              spacing: 10,

              runSpacing: 10,

              children: [

                SizedBox(

                  width: 220,

                  child: TextField(

                    controller: sponsorName,

                    decoration: const InputDecoration(

                      labelText: 'Nombre patrocinador',

                      border: OutlineInputBorder(),

                    ),

                  ),

                ),

                SizedBox(

                  width: 160,

                  child: TextField(

                    controller: sponsorPhone,

                    decoration: const InputDecoration(

                      labelText: 'Telefono',

                      border: OutlineInputBorder(),

                    ),

                  ),

                ),

                SizedBox(

                  width: 240,

                  child: TextField(

                    controller: sponsorEmail,

                    decoration: const InputDecoration(

                      labelText: 'Correo',

                      border: OutlineInputBorder(),

                    ),

                  ),

                ),

              ],

            ),

          const SizedBox(height: 10),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: [

              SizedBox(

                width: 180,

                child: DropdownButtonFormField<String>(

                  initialValue: sponsorContributionType,

                  decoration: const InputDecoration(

                    labelText: 'Tipo aporte',

                    border: OutlineInputBorder(),

                  ),

                  items: const ['Economica', 'Especie']

                      .map(

                        (item) => DropdownMenuItem(

                          value: item,

                          child: Text(item),

                        ),

                      )

                      .toList(),

                  onChanged: (value) => setState(() {

                    sponsorContributionType = value ?? 'Economica';

                    if (sponsorContributionType == 'Especie') {

                      sponsorAmount.clear();

                    }

                  }),

                ),

              ),

              SizedBox(

                width: 160,

                child: TextField(

                  controller: sponsorAmount,

                  enabled: sponsorContributionType == 'Economica',

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(

                    labelText: 'Monto',

                    border: OutlineInputBorder(),

                  ),

                ),

              ),

              SizedBox(

                width: 320,

                child: TextField(

                  controller: sponsorDescription,

                  decoration: const InputDecoration(

                    labelText: 'Descripcion aporte',

                    border: OutlineInputBorder(),

                  ),

                ),

              ),

            ],

          ),

        ],

      ],

    ),

  );



  Widget _selectionPanel() => Column(

    children: [

      CardBox(

        title: 'Peliculas seleccionadas',

        subtitle: '${selectedMovies.length} peliculas para la edicion',

        child: _checkList(

          widget.movies

              .map((movie) => (movie.id, '${movie.title} (${movie.year})'))

              .toList(),

          selectedMovies,

        ),

      ),

      const SizedBox(height: 16),

      CardBox(

        title: 'Jurados asignados',

        subtitle: '${selectedJurors.length} miembros para categorias',

        child: Column(

          children: [

            Align(

              alignment: Alignment.centerLeft,

              child: OutlinedButton.icon(

                onPressed: _openJurorDialog,

                icon: const Icon(Icons.person_add_alt_1_outlined),

                label: const Text('Nuevo jurado'),

              ),

            ),

            const SizedBox(height: 10),

            _checkList(

              availableJurors

                  .map((juror) => (juror.id, '${juror.name} - ${juror.role}'))

                  .toList(),

              selectedJurors,

            ),

          ],

        ),

      ),

    ],

  );



  Future<void> _openJurorDialog() async {

    final draft = await showDialog<JuryDraft>(

      context: context,

      builder: (context) => const JuryFormDialog(),

    );

    if (draft == null) return;

    setState(() {

      saving = true;

      message = null;

    });

    try {

      final juror = await DatabaseGateway.createJuror(draft);

      widget.onJurorAdd(juror);

      setState(() {

        availableJurors = mergeJuryMembers(availableJurors, [juror]);

        selectedJurors.add(juror.id);

        saving = false;

        message = 'Jurado "${juror.name}" registrado y asignado.';

      });

    } on DatabaseException catch (error) {

      setState(() {

        saving = false;

        message = 'Error: ${error.friendlyMessage}';

      });

    }

  }



  Widget _checkList(List<(String, String)> items, Set<String> selected) {

    if (items.isEmpty) {

      return const Text('No hay datos disponibles.', style: TextStyle(color: muted));

    }

    return Column(

      children: items.map((item) {

        final checked = selected.contains(item.$1);

        return Container(

          margin: const EdgeInsets.only(bottom: 8),

          decoration: BoxDecoration(

            color: checked ? surface2 : surface,

            borderRadius: BorderRadius.circular(radiusSm),

            border: Border.all(color: checked ? gold : line, width: 1.1),

          ),

          child: CheckboxListTile(

            dense: true,

            value: checked,

            title: Text(

              item.$2,

              style: TextStyle(

                color: text,

                fontWeight: checked ? FontWeight.w800 : FontWeight.w600,

              ),

            ),

            onChanged: (value) => setState(() {

              if (value == true) {

                selected.add(item.$1);

              } else {

                selected.remove(item.$1);

              }

            }),

          ),

        );

      }).toList(),

    );

  }



  Future<void> _saveEdition() async {

    if (venueId == null ||

        selectedMovies.isEmpty ||

        selectedJurors.isEmpty ||

        selectedCategories.isEmpty) {

      setState(() {

        message =

            'Error: selecciona sede, peliculas, categorias y al menos un jurado.';

      });

      return;

    }

    if (includeSponsor &&

        ((createSponsor && sponsorName.text.trim().isEmpty) ||

            (!createSponsor && sponsorId == null))) {

      setState(() {

        message =

            'Error: selecciona un patrocinador existente o escribe el nombre del nuevo patrocinador.';

      });

      return;

    }



    setState(() {

      saving = true;

      message = null;

    });



    try {

      await DatabaseGateway.createFestivalEdition(

        FestivalEditionDraft(

          name: name.text.trim(),

          startDate: start.text.trim(),

          endDate: end.text.trim(),

          status: status,

          venueId: venueId!,

          movieIds: selectedMovies.toList(),

          categories: selectedCategories,

          jurorIds: selectedJurors.toList(),

          sponsor: includeSponsor

              ? SponsorDraft(

                  existingSponsorId: createSponsor ? null : sponsorId,

                  newSponsorName:

                      createSponsor ? sponsorName.text.trim() : null,

                  newSponsorPhone:

                      createSponsor ? sponsorPhone.text.trim() : null,

                  newSponsorEmail:

                      createSponsor ? sponsorEmail.text.trim() : null,

                  contributionType: sponsorContributionType,

                  amount: sponsorContributionType == 'Economica'

                      ? double.tryParse(sponsorAmount.text.trim())

                      : null,

                  description: sponsorDescription.text.trim(),

                )

              : null,

        ),

      );

      if (!mounted) return;

      setState(() {

        saving = false;

        message = null;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        saving = false;

        message = 'Error: ${error.friendlyMessage}';

      });

    }

  }

}

