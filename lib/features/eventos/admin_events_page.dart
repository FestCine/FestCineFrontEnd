part of '../../main.dart';

class AdminEventsPage extends StatefulWidget {

  const AdminEventsPage({

    super.key,

    required this.events,

    required this.rooms,

    required this.editions,

    required this.selectedEdition,

    required this.onEditionChanged,

    required this.onAdd,

  });



  final List<FestivalEvent> events;

  final List<RoomOption> rooms;

  final List<FestivalEdition> editions;

  final FestivalEdition selectedEdition;

  final ValueChanged<FestivalEdition> onEditionChanged;

  final ValueChanged<FestivalEvent> onAdd;



  @override

  State<AdminEventsPage> createState() => _AdminEventsPageState();

}



class _AdminEventsPageState extends State<AdminEventsPage> {

  final name = TextEditingController();

  final description = TextEditingController();

  final capacity = TextEditingController(text: '40');

  final cost = TextEditingController(text: '0');

  final date = TextEditingController(text: '2026-08-13');

  final time = TextEditingController(text: '18:00');

  final duration = TextEditingController(text: '120');

  String type = 'Masterclass';

  String? roomId;

  String? message;

  bool messageIsError = false;

  bool saving = false;



  @override

  void initState() {

    super.initState();

    roomId = widget.rooms.isEmpty ? null : widget.rooms.first.id;

  }



  @override

  void didUpdateWidget(covariant AdminEventsPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    if (roomId == null || !widget.rooms.any((item) => item.id == roomId)) {

      roomId = widget.rooms.isEmpty ? null : widget.rooms.first.id;

    }

  }



  @override

  void dispose() {

    name.dispose();

    description.dispose();

    capacity.dispose();

    cost.dispose();

    date.dispose();

    time.dispose();

    duration.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Header(

          'Eventos',

          'Administrador: crea eventos paralelos, talleres, cocteles y masterclass',

        ),

        const SizedBox(height: 16),

        SizedBox(

          width: 320,

          child: DropdownButtonFormField<String>(

            initialValue: widget.selectedEdition.id,

            isExpanded: true,

            decoration: const InputDecoration(labelText: 'Edicion de eventos'),

            items: widget.editions

                .map(

                  (edition) => DropdownMenuItem(

                    value: edition.id,

                    child: Text(edition.name),

                  ),

                )

                .toList(),

            onChanged: saving

                ? null

                : (id) {

                    final edition = widget.editions.firstWhere(

                      (item) => item.id == id,

                      orElse: () => widget.selectedEdition,

                    );

                    widget.onEditionChanged(edition);

                  },

          ),

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

    final rooms = widget.rooms.isEmpty ? fallbackRoomOptions : widget.rooms;

    final selectedRoomId = rooms.any((item) => item.id == roomId)

        ? roomId

        : rooms.first.id;

    final editionBlockReason = _editionBlockReason(widget.selectedEdition);

    final canCreateEvent = _editionAllowsEventCreation(widget.selectedEdition);

    return CardBox(

      title: 'Nuevo evento',

      subtitle: 'El evento se registrara en ${widget.selectedEdition.name}',

      accent: gold,

      child: Column(

        children: [

          if (editionBlockReason != null) ...[

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: red.withValues(alpha: .10),

                borderRadius: BorderRadius.circular(radiusSm),

                border: Border.all(color: red.withValues(alpha: .35)),

              ),

              child: Text(

                editionBlockReason,

                style: const TextStyle(color: red, fontWeight: FontWeight.w700),

              ),

            ),

            const SizedBox(height: 10),

          ],

          TextField(

            controller: name,

            decoration: const InputDecoration(labelText: 'Nombre del evento'),

          ),

          const SizedBox(height: 10),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: [

              SizedBox(

                width: 190,

                child: DropdownButtonFormField<String>(

                  initialValue: type,

                  isExpanded: true,

                  decoration: const InputDecoration(labelText: 'Tipo de evento'),

                  items: const ['Masterclass', 'Taller', 'Coctel']

                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))

                      .toList(),

                  onChanged: (value) => setState(() => type = value ?? type),

                ),

              ),

              SizedBox(

                width: 240,

                child: DropdownButtonFormField<String>(

                  initialValue: selectedRoomId,

                  isExpanded: true,

                  decoration: const InputDecoration(labelText: 'Sala'),

                  items: rooms

                      .map((item) => DropdownMenuItem(value: item.id, child: Text(item.label)))

                      .toList(),

                  onChanged: (value) => setState(() => roomId = value),

                ),

              ),

              SizedBox(

                width: 130,

                child: TextField(

                  controller: capacity,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(labelText: 'Aforo'),

                ),

              ),

              SizedBox(

                width: 130,

                child: TextField(

                  controller: cost,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(labelText: 'Costo'),

                ),

              ),

              SizedBox(

                width: 150,

                child: TextField(

                  controller: date,

                  decoration: const InputDecoration(labelText: 'Fecha'),

                ),

              ),

              SizedBox(

                width: 110,

                child: TextField(

                  controller: time,

                  readOnly: true,

                  decoration: const InputDecoration(

                    labelText: 'Hora',

                    suffixIcon: Icon(Icons.schedule),

                  ),

                  onTap: saving ? null : _pickEventTime,

                ),

              ),

              SizedBox(

                width: 140,

                child: TextField(

                  controller: duration,

                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(labelText: 'Duracion min'),

                ),

              ),

            ],

          ),

          const SizedBox(height: 10),

          TextField(

            controller: description,

            minLines: 3,

            maxLines: 4,

            decoration: const InputDecoration(labelText: 'Descripcion'),

          ),

          const SizedBox(height: 14),

          Align(

            alignment: Alignment.centerLeft,

            child: FilledButton.icon(

              onPressed: saving || !canCreateEvent ? null : _createEvent,

              icon: saving

                  ? const SizedBox(

                      width: 18,

                      height: 18,

                      child: CircularProgressIndicator(strokeWidth: 2),

                    )

                  : const Icon(Icons.event_available_outlined),

              label: Text(saving ? 'Creando evento...' : 'Crear evento'),

            ),

          ),

        ],

      ),

    );

  }



  Widget _list() {

    final items = widget.events

        .where((item) => item.editionId == widget.selectedEdition.id)

        .toList();

    return CardBox(

      title: 'Eventos registrados',

      subtitle: 'Eventos de ${widget.selectedEdition.name}',

      child: Column(

        children: items.map((item) {

          return Padding(

            padding: const EdgeInsets.only(bottom: 12),

            child: Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: surface2,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: line),

              ),

              child: Row(

                children: [

                  BadgeIcon(Icons.event_available_outlined, gold, compact: true),

                  const SizedBox(width: 12),

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Text(

                          item.name,

                          style: const TextStyle(

                            color: text,

                            fontWeight: FontWeight.w800,

                          ),

                        ),

                        Text(

                          '${item.type} - ${item.room} - ${item.dateLabel} ${item.timeLabel}',

                          style: const TextStyle(color: muted, fontSize: 12),

                        ),

                        Text(

                          'Aforo ${item.sold}/${item.capacity} - Bs ${item.cost.toStringAsFixed(2)}',

                          style: const TextStyle(color: muted, fontSize: 12),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

          );

        }).toList(),

      ),

    );

  }



  Future<void> _pickEventTime() async {

    final parts = time.text.split(':');

    final initialHour = parts.isNotEmpty ? int.tryParse(parts.first) ?? 18 : 18;

    final initialMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final picked = await showTimePicker(

      context: context,

      initialTime: TimeOfDay(

        hour: initialHour.clamp(0, 23),

        minute: initialMinute.clamp(0, 59),

      ),

    );

    if (picked == null) return;

    setState(() {

      time.text =

          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

    });

  }



  Future<void> _createEvent() async {

    final cleanName = name.text.trim();

    final selectedRoom = (widget.rooms.isEmpty ? fallbackRoomOptions : widget.rooms)

        .firstWhere(

          (item) => item.id == roomId,

          orElse: () => (widget.rooms.isEmpty ? fallbackRoomOptions : widget.rooms).first,

        );

    if (cleanName.isEmpty) {

      setState(() {

        message = 'Escribe el nombre del evento antes de crearlo.';

        messageIsError = true;

      });

      return;

    }

    final editionBlockReason = _editionBlockReason(widget.selectedEdition);

    if (editionBlockReason != null) {

      setState(() {

        message = editionBlockReason;

        messageIsError = true;

      });

      return;

    }

    final eventDateTime = DateTime.tryParse('${date.text.trim()}T${time.text.trim()}:00');

    if (eventDateTime == null) {

      setState(() {

        message = 'La fecha u hora del evento no tiene un formato valido.';

        messageIsError = true;

      });

      return;

    }

    final eventDateBlockReason = _eventDateBlockReason(widget.selectedEdition, eventDateTime);

    if (eventDateBlockReason != null) {

      setState(() {

        message = eventDateBlockReason;

        messageIsError = true;

      });

      return;

    }

    setState(() {

      saving = true;

      message = 'Guardando evento en el backend...';

      messageIsError = false;

    });

    try {

      final created = await DatabaseGateway.createFestivalEvent(

        EventDraft(

          name: cleanName,

          type: type,

          description: description.text.trim().isEmpty

              ? 'Evento agregado desde el panel administrativo.'

              : description.text.trim(),

          capacity: int.tryParse(capacity.text.trim()) ?? 40,

          cost: double.tryParse(cost.text.trim().replaceAll(',', '.')) ?? 0,

          date: date.text.trim(),

          time: time.text.trim(),

          durationMinutes: int.tryParse(duration.text.trim()) ?? 120,

          editionId: widget.selectedEdition.id,

          room: selectedRoom,

        ),

      );

      widget.onAdd(created);

      setState(() {

        saving = false;

        message = '"$cleanName" fue creado correctamente.';

        messageIsError = false;

        name.clear();

        description.clear();

      });

    } on DatabaseException catch (error) {

      setState(() {

        saving = false;

        message = error.friendlyMessage;

        messageIsError = true;

      });

    }

  }

}

