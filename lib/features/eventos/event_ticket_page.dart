part of '../../main.dart';

class EventTicketPage extends StatefulWidget {

  const EventTicketPage({

    super.key,

    required this.attendees,

    required this.people,

    required this.events,

    required this.edition,

    this.onDataChanged,

  });



  final List<Attendee> attendees;

  final List<PersonOption> people;

  final List<FestivalEvent> events;

  final FestivalEdition edition;

  final Future<void> Function()? onDataChanged;



  @override

  State<EventTicketPage> createState() => _EventTicketPageState();

}



class _EventTicketPageState extends State<EventTicketPage> {

  FestivalEvent? event;

  Attendee? attendee;

  PersonOption? selectedPerson;

  final firstName = TextEditingController();

  final lastName = TextEditingController();

  final email = TextEditingController();

  final phone = TextEditingController();

  final nit = TextEditingController();

  String paymentMethod = 'Efectivo';

  String? message;

  bool messageIsError = false;

  bool saving = false;

  PurchaseReceipt? receipt;



  @override

  void initState() {

    super.initState();

    event = _preferredEvent(_eventsForEdition());

    attendee = widget.attendees.isEmpty ? null : widget.attendees.first;

    if (attendee != null) _fillAttendee(attendee!);

  }



  @override

  void didUpdateWidget(covariant EventTicketPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    final editionEvents = _eventsForEdition();

    if (event == null || !editionEvents.any((item) => item.id == event!.id)) {

      event = _preferredEvent(editionEvents);

    }

  }



  @override

  void dispose() {

    firstName.dispose();

    lastName.dispose();

    email.dispose();

    phone.dispose();

    nit.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    final events = _eventsForEdition();

    final current = events.any((item) => item.id == event?.id)

        ? event!

        : (events.isEmpty ? null : events.first);



    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Header(

          'Eventos',

          'Venta de entradas para eventos de ${widget.edition.name}',

          trailing: const Pill('EVENTOS', color: gold),

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

        _centeredPanel(

          CardBox(

            title: receipt == null ? 'Entrada para evento' : 'Venta confirmada',

            subtitle: receipt == null

                ? 'Selecciona un evento y registra a la persona'

                : 'Operacion registrada correctamente',

            accent: gold,

            child: receipt == null

                ? Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                DropdownButtonFormField<String>(

                  initialValue: current?.id,

                  isExpanded: true,

                  decoration: const InputDecoration(labelText: 'Evento disponible'),

                  items: events

                      .map(

                        (item) => DropdownMenuItem(

                          value: item.id,

                          child: Text(

                            '${item.name} - ${item.type} - Bs ${item.cost.toStringAsFixed(2)}',

                          ),

                        ),

                      )

                      .toList(),

                  onChanged: saving

                      ? null

                      : (id) => setState(() {

                            event = events.firstWhere(

                              (item) => item.id == id,

                              orElse: () => current ?? events.first,

                            );

                          }),

                ),

                if (current != null) ...[

                  const SizedBox(height: 8),

                  Text(

                    '${current.room} - ${current.dateLabel} ${current.timeLabel} - Aforo ${current.sold}/${current.capacity}',

                    style: const TextStyle(color: muted, fontSize: 12),

                  ),

                ],

                const SizedBox(height: 14),

                Wrap(

                  spacing: 10,

                  runSpacing: 10,

                  children: [

                    SizedBox(

                      width: 220,

                      child: TextField(

                        controller: firstName,

                        onChanged: (_) => _markPersonDirty(),

                        decoration: const InputDecoration(labelText: 'Nombre persona'),

                      ),

                    ),

                    SizedBox(

                      width: 220,

                      child: TextField(

                        controller: lastName,

                        onChanged: (_) => _markPersonDirty(),

                        decoration: const InputDecoration(labelText: 'Apellido persona'),

                      ),

                    ),

                    SizedBox(

                      width: 260,

                      child: TextField(

                        controller: email,

                        onChanged: (_) => _markPersonDirty(),

                        decoration: const InputDecoration(labelText: 'Correo'),

                      ),

                    ),

                    SizedBox(

                      width: 180,

                      child: TextField(

                        controller: phone,

                        onChanged: (_) => _markPersonDirty(),

                        decoration: const InputDecoration(labelText: 'Telefono'),

                      ),

                    ),

                    _personMatches(),

                    SizedBox(

                      width: 220,

                      child: DropdownButtonFormField<String>(

                        initialValue: paymentMethod,

                        decoration: const InputDecoration(labelText: 'Metodo de pago'),

                        items: const ['Efectivo', 'Tarjeta', 'QR', 'Transferencia']

                            .map((item) => DropdownMenuItem(value: item, child: Text(item)))

                            .toList(),

                        onChanged: saving

                            ? null

                            : (value) => setState(() {

                                  paymentMethod = value ?? 'Efectivo';

                                }),

                      ),

                    ),

                    SizedBox(

                      width: 220,

                      child: TextField(

                        controller: nit,

                        decoration: const InputDecoration(labelText: 'NIT / CI factura'),

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 18),

                FilledButton.icon(

                  onPressed:

                      saving || current == null || !_personFormValid

                          ? null

                          : _confirm,

                  icon: saving

                      ? const SizedBox(

                          width: 18,

                          height: 18,

                          child: CircularProgressIndicator(strokeWidth: 2),

                        )

                      : const Icon(Icons.event_available_outlined),

                  label: Text(saving ? 'Vendiendo evento...' : 'Confirmar entrada de evento'),

                ),

              ],

            )

                : _eventReceipt(current),

          ),

        ),

      ],

    );

  }



  Widget _eventReceipt(FestivalEvent? current) {

    final currentReceipt = receipt;

    if (currentReceipt == null) return const SizedBox.shrink();

    final eventName = current?.name ?? event?.name ?? 'Evento';

    final eventDetail = current == null

        ? 'Entrada de evento'

        : '${current.type} - ${current.room} - ${current.dateLabel} ${current.timeLabel}';

    final attendeeName = attendee?.displayName ??

        selectedPerson?.displayName ??

        '${firstName.text.trim()} ${lastName.text.trim()}'.trim();

    final paidWithQr = normalizeText(currentReceipt.metodoPago) == 'qr';

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Icon(Icons.check_circle, color: green, size: 54),

        const SizedBox(height: 12),

        Text(

          eventName,

          style: const TextStyle(

            color: text,

            fontSize: 24,

            fontWeight: FontWeight.w800,

          ),

        ),

        Text(eventDetail, style: const TextStyle(color: muted)),

        const SizedBox(height: 14),

        Text(

          'Persona: ${attendeeName.isEmpty ? "No registrada" : attendeeName}',

          style: const TextStyle(color: text),

        ),

        Text(

          'Pago: ${currentReceipt.metodoPago} - NIT/CI: ${nit.text.trim().isEmpty ? "S/N" : nit.text.trim()}',

          style: const TextStyle(color: text),

        ),

        Text(

          'Total: Bs ${currentReceipt.montoPagado.toStringAsFixed(2)}',

          style: const TextStyle(

            color: gold,

            fontSize: 18,

            fontWeight: FontWeight.w800,

          ),

        ),

        const SizedBox(height: 4),

        Row(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            if (paidWithQr) ...[

              GenericQr(label: currentReceipt.codigoEntrada),

              const SizedBox(width: 12),

            ],

            Expanded(

              child: Text(

                'Codigo: ${currentReceipt.codigoEntrada}\nFactura: ${currentReceipt.idFactura}\nMetodo de pago: ${currentReceipt.metodoPago}',

                style: const TextStyle(color: muted, fontSize: 12),

              ),

            ),

          ],

        ),

        const SizedBox(height: 8),

        const Text(

          'Compra procesada correctamente y validada contra aforo disponible.',

          style: TextStyle(color: green, fontSize: 12),

        ),

        const SizedBox(height: 18),

        OutlinedButton.icon(

          onPressed: () => setState(() {

            receipt = null;

            message = null;

            attendee = null;

            selectedPerson = null;

            firstName.clear();

            lastName.clear();

            email.clear();

            phone.clear();

            nit.clear();

          }),

          icon: const Icon(Icons.add),

          label: const Text('Nueva venta'),

        ),

      ],

    );

  }



  Widget _centeredPanel(Widget child, {double maxWidth = 760}) {

    return SizedBox(

      width: double.infinity,

      child: Center(

        child: ConstrainedBox(

          constraints: BoxConstraints(maxWidth: maxWidth),

          child: child,

        ),

      ),

    );

  }



  void _fillAttendee(Attendee item) {

    firstName.text = item.firstName.isEmpty ? item.name : item.firstName;

    lastName.text = item.lastName;

    email.text = item.email;

    phone.text = item.phone;

    selectedPerson = item.idPersona.isEmpty

        ? null

        : PersonOption.fromAttendee(item);

  }



  Widget _personMatches() {

    final suggestions = _personSuggestions().take(5).toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return SizedBox(

      width: 520,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.center,

        children: [

          const Text(

            'Coincidencias encontradas',

            style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 12),

          ),

          const SizedBox(height: 6),

          ...suggestions.map((item) {

            final person = item.person;

            final selected = selectedPerson?.id == person.id;

            final details = [

              person.id,

              if (person.email.trim().isNotEmpty) person.email,

            ].where((part) => part.trim().isNotEmpty).join(' - ');

            return Padding(

              padding: const EdgeInsets.only(bottom: 6),

              child: OutlinedButton.icon(

                onPressed: saving ? null : () => _fillPersonMatch(item),

                icon: Icon(

                  selected

                      ? Icons.check_circle_outline

                      : Icons.person_search_outlined,

                ),

                label: Text(

                  details.isEmpty

                      ? 'Usar ${person.displayName}'

                      : 'Usar ${person.displayName} ($details)',

                ),

              ),

            );

          }),

          if (selectedPerson != null)

            Text(

              'Coincidencia detectada: ${selectedPerson!.displayName} (${selectedPerson!.id})',

              textAlign: TextAlign.center,

              style: const TextStyle(color: muted, fontSize: 12),

            ),

        ],

      ),

    );

  }



  void _markPersonDirty() {

    final suggestions = _personSuggestions();

    final match = suggestions.isEmpty ? null : suggestions.first;

    setState(() {

      selectedPerson = match?.person;

      attendee = match?.attendee;

    });

  }



  List<PersonMatch> _personSuggestions() {

    final fullName = normalizeText('${firstName.text} ${lastName.text}');

    final emailQuery = email.text.trim().toLowerCase();

    final phoneQuery = onlyDigits(phone.text);

    if (fullName.length < 3 && emailQuery.length < 3 && phoneQuery.length < 3) {

      return const [];

    }



    final sourcePeople = widget.people.isEmpty

        ? widget.attendees.map((item) => PersonOption.fromAttendee(item)).toList()

        : widget.people;

    final matches = sourcePeople

        .where(

          (person) =>

              _personMatchScore(person, fullName, emailQuery, phoneQuery) > 0,

        )

        .map((person) => PersonMatch(person, _attendeeForPerson(person)))

        .toList()

      ..sort((a, b) {

        final score = _personMatchScore(

          b.person,

          fullName,

          emailQuery,

          phoneQuery,

        ).compareTo(

          _personMatchScore(a.person, fullName, emailQuery, phoneQuery),

        );

        if (score != 0) return score;

        return a.person.displayName.compareTo(b.person.displayName);

      });

    return matches;

  }



  int _personMatchScore(

    PersonOption person,

    String fullName,

    String emailQuery,

    String phoneQuery,

  ) {

    var score = 0;

    final candidateName = normalizeText(

      '${person.firstName} ${person.lastName} ${person.displayName}',

    );

    final candidateEmail = person.email.toLowerCase();

    final candidatePhone = onlyDigits(person.phone);



    if (fullName.length >= 3) {

      if (candidateName == fullName) score += 120;

      if (candidateName.contains(fullName) || fullName.contains(candidateName)) {

        score += 100;

      }

      if (fuzzyScore(candidateName, fullName) >= 0.72) score += 80;

    }

    if (emailQuery.isNotEmpty && candidateEmail == emailQuery) score += 60;

    if (phoneQuery.isNotEmpty && candidatePhone == phoneQuery) score += 50;

    return score;

  }



  Attendee? _attendeeForPerson(PersonOption person) {

    final personId = person.id;

    final emailQuery = person.email.toLowerCase();

    final phoneQuery = onlyDigits(person.phone);

    final fullName = normalizeText(person.displayName);

    for (final item in widget.attendees) {

      final samePersonId = personId.isNotEmpty && item.idPersona == personId;

      final sameEmail =

          emailQuery.isNotEmpty && item.email.toLowerCase() == emailQuery;

      final samePhone =

          phoneQuery.isNotEmpty && onlyDigits(item.phone) == phoneQuery;

      final sameName = fullName.isNotEmpty &&

          normalizeText('${item.firstName} ${item.lastName} ${item.name}') ==

              fullName;

      if (samePersonId || sameEmail || samePhone || sameName) return item;

    }

    return null;

  }



  bool get _personFormValid =>

      firstName.text.trim().isNotEmpty && lastName.text.trim().isNotEmpty;



  void _fillPersonMatch(PersonMatch match) {

    firstName.text = match.person.firstName.isEmpty

        ? match.person.displayName

        : match.person.firstName;

    lastName.text = match.person.lastName;

    email.text = match.person.email;

    phone.text = match.person.phone;

    setState(() {

      selectedPerson = match.person;

      attendee = match.attendee;

    });

  }



  FestivalEvent? _preferredEvent(List<FestivalEvent> items) {

    if (items.isEmpty) return null;

    return items.first;

  }



  List<FestivalEvent> _eventsForEdition() {

    return widget.events

        .where((item) => item.editionId == widget.edition.id)

        .toList();

  }



  Future<void> _confirm() async {

    final events = _eventsForEdition();

    final selectedEvent = events.any((item) => item.id == event?.id)

        ? event

        : (events.isEmpty ? null : events.first);

    if (selectedEvent == null) return;

    setState(() {

      saving = true;

      message = null;

    });

    try {

      final resolved = await DatabaseGateway.resolveAttendee(

        widget.edition.id,

        AttendeeFormData(

          idPersona: selectedPerson?.id ?? attendee?.idPersona ?? '',

          firstName: firstName.text.trim(),

          lastName: lastName.text.trim(),

          email: email.text.trim(),

          phone: phone.text.trim(),

        ),

      );

      final response = await DatabaseGateway.venderEntradaEvento(

        attendee: resolved.attendee,

        event: selectedEvent,

        metodoPago: paymentMethod,

        nit: nit.text.trim().isEmpty ? null : nit.text.trim(),

      );

      if (widget.onDataChanged != null) await widget.onDataChanged!();

      if (!mounted) return;

      setState(() {

        saving = false;

        messageIsError = false;

        message = null;

        attendee = resolved.attendee;

        event = selectedEvent;

        receipt = response;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        saving = false;

        messageIsError = true;

        message = error.friendlyMessage;

      });

    }

  }

}

