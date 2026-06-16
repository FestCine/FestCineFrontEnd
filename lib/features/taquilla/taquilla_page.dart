part of '../../main.dart';

class TaquillaPage extends StatefulWidget {

  const TaquillaPage({

    super.key,

    required this.movies,

    required this.attendees,

    required this.people,

    required this.editionId,

    required this.subscriptionTypes,

    required this.accreditationTypes,

  });



  final List<Movie> movies;

  final List<Attendee> attendees;

  final List<PersonOption> people;

  final String editionId;

  final List<SubscriptionType> subscriptionTypes;

  final List<AccreditationType> accreditationTypes;



  @override

  State<TaquillaPage> createState() => _TaquillaPageState();

}



class _TaquillaPageState extends State<TaquillaPage> {

  int step = 1;

  Movie? movie;

  Session? session;

  Attendee? attendee;

  PersonOption? selectedPerson;

  final attendeeName = TextEditingController();

  final attendeeLastName = TextEditingController();

  final attendeeEmail = TextEditingController();

  final attendeePhone = TextEditingController();

  final nit = TextEditingController();

  final selectedSeats = <String>{};

  SaleMode saleMode = SaleMode.ticket;

  String rate = 'General';

  String paymentMethod = 'Efectivo';

  SubscriptionType? subscriptionType;

  List<OwnedPass> accreditedPasses = const [];

  String? selectedAccreditedPassId;

  bool loadingAccreditedPasses = false;

  ActiveAccreditation? activeAccreditation;

  String? selectedAccreditationTypeId;

  bool loadingAccreditation = false;

  String? message;

  bool purchaseError = false;

  bool purchasing = false;

  PurchaseReceipt? receipt;



  @override

  void initState() {

    super.initState();

    attendee = _preferredAttendee(widget.attendees);

    if (attendee != null) _fillAttendee(attendee!, notify: false);

    subscriptionType = _preferredSubscriptionType(widget.subscriptionTypes);

  }



  @override

  void dispose() {

    attendeeName.dispose();

    attendeeLastName.dispose();

    attendeeEmail.dispose();

    attendeePhone.dispose();

    nit.dispose();

    super.dispose();

  }



  @override

  void didUpdateWidget(covariant TaquillaPage oldWidget) {

    super.didUpdateWidget(oldWidget);

    final selected = attendee;

    if (selected == null ||

        !widget.attendees.any((item) => item.id == selected.id)) {

      attendee = _preferredAttendee(widget.attendees);

      if (attendee != null) _fillAttendee(attendee!, notify: false);

    }

    if (subscriptionType == null ||

        !widget.subscriptionTypes.any((item) => item.id == subscriptionType!.id)) {

      subscriptionType = _preferredSubscriptionType(widget.subscriptionTypes);

    }

  }



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Header(

          'Taquilla',

          saleMode == SaleMode.ticket

              ? 'Venta guiada de entradas para FestCine XII'

              : 'Venta de abonos por tipo de acceso',

          trailing: saleMode == SaleMode.ticket

              ? StepperPills(step)

              : const Pill('ABONOS', color: purple),

        ),

        const SizedBox(height: 18),

        if (message != null) ...[

          AlertBanner(

            message!,

            purchaseError ? red : green,

            onClose: () => setState(() => message = null),

          ),

          const SizedBox(height: 12),

        ],

        Center(child: _saleModeControl()),

        const SizedBox(height: 16),

        if (saleMode == SaleMode.ticket && step == 1) _movies(),

        if (saleMode == SaleMode.ticket && step == 2) _sessions(),

        if (saleMode == SaleMode.ticket && step == 3) _seats(),

        if (saleMode == SaleMode.ticket && step == 4) _confirmation(),

        if (saleMode == SaleMode.subscription && step != 4) _subscriptionSale(),

        if (saleMode == SaleMode.subscription && step == 4) _confirmation(),

      ],

    );

  }



  Widget _saleModeControl() => SegmentedButton<SaleMode>(

    segments: const [

      ButtonSegment(

        value: SaleMode.ticket,

        label: Text('Entrada'),

        icon: Icon(Icons.confirmation_number_outlined),

      ),

      ButtonSegment(

        value: SaleMode.subscription,

        label: Text('Abono'),

        icon: Icon(Icons.workspace_premium_outlined),

      ),

    ],

    selected: {saleMode},

    onSelectionChanged: purchasing

        ? null

        : (value) => setState(() {

              saleMode = value.first;

              step = 1;

              receipt = null;

              message = null;

              selectedSeats.clear();

            }),

  );



  Widget _centeredPanel(Widget child, {double maxWidth = 980}) {

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



  Widget _subscriptionSale() {

    final availableTypes = widget.subscriptionTypes.isEmpty

        ? fallbackSubscriptionTypes

        : widget.subscriptionTypes;

    final current = availableTypes.any((item) => item.id == subscriptionType?.id)

        ? subscriptionType!

        : (_preferredSubscriptionType(availableTypes) ??

            fallbackSubscriptionTypes.first);

    return _centeredPanel(

      CardBox(

        title: 'Venta de abono',

        subtitle: 'Selecciona el tipo de abono y registra la persona',

        accent: purple,

        child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          DropdownButtonFormField<String>(

            initialValue: current.id,

            isExpanded: true,

            decoration: const InputDecoration(

              labelText: 'Tipo de abono',

              border: OutlineInputBorder(),

            ),

            items: availableTypes

                .map(

                  (item) => DropdownMenuItem(

                    value: item.id,

                    child: Text(

                      '${item.name} - Bs ${item.price.toStringAsFixed(2)}',

                    ),

                  ),

                )

                .toList(),

            onChanged: purchasing

                ? null

                : (id) => setState(() {

                      subscriptionType = availableTypes.firstWhere(

                        (item) => item.id == id,

                        orElse: () => current,

                      );

                      if (subscriptionType?.price == 0 && rate == 'General') {

                        rate = 'VIP';

                      }

                    }),

          ),

          const SizedBox(height: 8),

          Text(

            current.description.isEmpty

                ? 'Abono disponible para la edicion seleccionada.'

                : current.description,

            style: const TextStyle(color: muted, fontSize: 12, height: 1.35),

          ),

          const SizedBox(height: 14),

          Wrap(

            spacing: 8,

            runSpacing: 8,

            children: ['General', 'Estudiante', 'Jubilado', 'Acreditado', 'VIP']

                .map(

              (r) {

                return ChoiceChip(

                  label: Text(r),

                  selected: rate == r,

                  selectedColor: purple.withValues(alpha: .2),

                  onSelected: purchasing
                      ? null
                      : (_) => setState(() {

                            rate = r;

                            if (!_isAccreditationRate(r)) {

                              selectedAccreditationTypeId = null;

                            }

                          }),

                );

              },

            ).toList(),

          ),

          const SizedBox(height: 14),

          _attendeeForm(),

          const SizedBox(height: 14),

          _paymentFields(),

          const SizedBox(height: 18),

          FilledButton.icon(

            onPressed: !_attendeeFormValid || purchasing

                ? null

                : _confirmSubscriptionPurchase,

            icon: purchasing

                ? const SizedBox(

                    width: 18,

                    height: 18,

                    child: CircularProgressIndicator(strokeWidth: 2),

                  )

                : const Icon(Icons.workspace_premium_outlined),

            label: Text(purchasing ? 'Registrando abono...' : 'Confirmar abono'),

          ),

        ],

        ),

      ),

    );

  }



  Widget _movies() => ResponsiveGrid(

    minWidth: 300,

    aspectRatio: .66,

    children: widget.movies.map((m) {

      return MovieCard(

        movie: m,

        onTap: () => setState(() {

          movie = m;

          step = 2;

        }),

      );

    }).toList(),

  );



  Widget _sessions() => Column(

    children: [

      BackLine('Elegiste: ${movie!.title}', () => setState(() => step = 1)),

      const SizedBox(height: 12),

      ResponsiveGrid(

        minWidth: 260,

        aspectRatio: 1.2,

        children: movie!.sessions.map((s) {

          final capacity = s.capacity == 0 ? roomCapacity(s.room) : s.capacity;

          final pct = ((s.occupied.length / capacity) * 100).round();

          return ActionCard(

            icon: Icons.schedule,

            title: '${s.date} - ${s.time}',

            subtitle:

                '${s.room} - ${s.qa ? "Q&A incluido" : "Funcion regular"}',

            footer: '$pct% vendido',

            color: pct > 70 ? red : green,

            onTap: () {

              setState(() {

                session = s;

                selectedSeats.clear();

                selectedAccreditedPassId = null;

                accreditedPasses = const [];

                step = 3;

              });

              if (attendee != null) {

                _loadAttendeeAccreditation(attendee!);

                _loadAccreditedPasses(attendee!);

              }

            },

          );

        }).toList(),

      ),

    ],

  );



  Widget _seats() => _centeredPanel(

    Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [

        BackLine(

          '${movie!.title} - ${session!.date} - ${session!.time}',

          () => setState(() => step = 2),

        ),

        const SizedBox(height: 12),

        CardBox(

          title: 'Seleccion de asientos',

          subtitle: 'Un boleto individual por operacion',

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              SeatMap(

                occupied: session!.occupied,

                selected: selectedSeats,

                onTap: (id) => setState(() {

                  if (selectedSeats.contains(id)) {

                    selectedSeats.remove(id);

                  } else if (!session!.occupied.contains(id)) {

                    selectedSeats.clear();

                    selectedSeats.add(id);

                  }

                }),

              ),

              const SizedBox(height: 18),

              Wrap(

                alignment: WrapAlignment.center,

                spacing: 8,

                runSpacing: 8,

                children: ['General', 'Estudiante', 'Jubilado', 'Acreditado', 'VIP']

                    .map(

                  (r) {

                    return ChoiceChip(

                      label: Text(r),

                      selected: rate == r,

                      selectedColor: gold,

                      checkmarkColor: Colors.white,

                      onSelected: (_) => _selectTicketRate(r),

                    );

                  },

                ).toList(),

              ),

              const SizedBox(height: 14),

              _attendeeForm(),

              const SizedBox(height: 14),

              _accreditationSelector(),

              const SizedBox(height: 14),

              _ownedPassSelector(),

              const SizedBox(height: 14),

              _paymentFields(),

              const SizedBox(height: 18),

              FilledButton.icon(

                onPressed:

                    selectedSeats.isEmpty || !_attendeeFormValid || purchasing

                        ? null

                        : _confirmPurchase,

                icon: purchasing

                    ? const SizedBox(

                        width: 18,

                        height: 18,

                        child: CircularProgressIndicator(strokeWidth: 2),

                      )

                    : const Icon(Icons.check_circle_outline),

                label: Text(

                  purchasing ? 'Reservando asiento...' : 'Confirmar entrada',

                ),

              ),

              const SizedBox(height: 10),

              const Text(

                'Al confirmar se reserva el asiento y se emite la factura.',

                textAlign: TextAlign.center,

                style: TextStyle(color: muted, fontSize: 12),

              ),

            ],

          ),

        ),

      ],

    ),

  );





  Widget _attendeeForm() {

    final suggestions = _attendeeSuggestions().take(5).toList();

    return Column(

      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        Wrap(

          alignment: WrapAlignment.center,

          spacing: 10,

          runSpacing: 10,

          children: [

            SizedBox(

              width: 220,

              child: TextField(

                controller: attendeeName,

                onChanged: (_) => _markAttendeeDirty(),

                decoration: const InputDecoration(

                  labelText: 'Nombre persona',

                  border: OutlineInputBorder(),

                ),

              ),

            ),

            SizedBox(

              width: 220,

              child: TextField(

                controller: attendeeLastName,

                onChanged: (_) => _markAttendeeDirty(),

                decoration: const InputDecoration(

                  labelText: 'Apellido persona',

                  border: OutlineInputBorder(),

                ),

              ),

            ),

            SizedBox(

              width: 260,

              child: TextField(

                controller: attendeeEmail,

                keyboardType: TextInputType.emailAddress,

                onChanged: (_) => _markAttendeeDirty(),

                decoration: const InputDecoration(

                  labelText: 'Correo',

                  border: OutlineInputBorder(),

                ),

              ),

            ),

            SizedBox(

              width: 180,

              child: TextField(

                controller: attendeePhone,

                keyboardType: TextInputType.phone,

                onChanged: (_) => _markAttendeeDirty(),

                decoration: const InputDecoration(

                  labelText: 'Telefono',

                  border: OutlineInputBorder(),

                ),

              ),

            ),

          ],

        ),

        if (suggestions.isNotEmpty) ...[

          const SizedBox(height: 10),

          const Text(

            'Coincidencias encontradas',

            textAlign: TextAlign.center,

            style: TextStyle(

              color: text,

              fontSize: 12,

              fontWeight: FontWeight.w800,

            ),

          ),

          const SizedBox(height: 6),

          Wrap(

            alignment: WrapAlignment.center,

            spacing: 8,

            runSpacing: 8,

            children: suggestions.map((item) {

              final detail = item.person.email.isEmpty

                  ? item.person.id

                  : '${item.person.id} - ${item.person.email}';

              return ActionChip(

                avatar: const Icon(Icons.person_search, size: 18),

                label: Text('Usar ${item.person.displayName} ($detail)'),

                onPressed: purchasing ? null : () => _fillPersonMatch(item),

              );

            }).toList(),

          ),

        ],

        const SizedBox(height: 8),

        Text(

          attendee == null

              ? selectedPerson == null

                  ? 'Si no existe, se registrara automaticamente antes de la compra.'

                  : 'Persona encontrada: ${selectedPerson!.displayName}. Se creara como asistente de esta edicion al confirmar.'

              : 'Coincidencia detectada: ${attendee!.displayName}',

          textAlign: TextAlign.center,

          style: const TextStyle(color: muted, fontSize: 12),

        ),

      ],

    );

  }



  Widget _paymentFields() => Wrap(

    alignment: WrapAlignment.center,

    spacing: 10,

    runSpacing: 10,

    children: [

      SizedBox(

        width: 220,

        child: DropdownButtonFormField<String>(

          initialValue: paymentMethod,

          decoration: const InputDecoration(

            labelText: 'Metodo de pago',

            border: OutlineInputBorder(),

          ),

          items: const ['Efectivo', 'Tarjeta', 'QR', 'Transferencia']

              .map(

                (method) => DropdownMenuItem(

                  value: method,

                  child: Text(method),

                ),

              )

              .toList(),

          onChanged: purchasing

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

          decoration: const InputDecoration(

            labelText: 'NIT / CI factura',

            border: OutlineInputBorder(),

          ),

        ),

      ),

    ],

  );



  Widget _accreditationSelector() {

    if (!_usesAccreditationRate) return const SizedBox.shrink();

    final types = widget.accreditationTypes.isEmpty

        ? fallbackAccreditationTypes

        : widget.accreditationTypes;

    final selectedId = selectedAccreditationTypeId ??

        activeAccreditation?.typeId ??

        (types.isEmpty ? null : types.first.id);

    final orderedTypes = [...types]..sort((a, b) {

        if (a.id == activeAccreditation?.typeId) return -1;

        if (b.id == activeAccreditation?.typeId) return 1;

        return a.name.compareTo(b.name);

      });



    if (loadingAccreditation) {

      return const SizedBox(width: 320, child: LinearProgressIndicator());

    }



    return SizedBox(

      width: 460,

      child: DropdownButtonFormField<String>(

        initialValue: orderedTypes.any((item) => item.id == selectedId) ? selectedId : null,

        isExpanded: true,

        decoration: InputDecoration(

          labelText: 'Tipo de acreditacion',

          helperText: activeAccreditation == null

              ? 'Si no tiene acreditacion, se creara al confirmar la compra.'

              : 'Acreditacion actual: ${activeAccreditation!.typeName}',

          border: const OutlineInputBorder(),

        ),

        items: orderedTypes.map((item) {

          final current = item.id == activeAccreditation?.typeId;

          return DropdownMenuItem(

            value: item.id,

            child: Text(current ? '${item.name} - actual' : item.name),

          );

        }).toList(),

        onChanged: purchasing

            ? null

            : (value) => setState(() {

                  selectedAccreditationTypeId = value;

                  purchaseError = false;

                  message = null;

                }),

      ),

    );

  }



  Widget _ownedPassSelector() {

    if (attendee == null) {

      return const Text(

        'Si la persona tiene abonos, se mostraran cuando exista como asistente.',

        textAlign: TextAlign.center,

        style: TextStyle(color: muted, fontSize: 12),

      );

    }

    if (loadingAccreditedPasses) {

      return const SizedBox(width: 320, child: LinearProgressIndicator());

    }

    if (accreditedPasses.isEmpty) {

      return const Text(

        'No hay abonos activos disponibles para esta persona.',

        textAlign: TextAlign.center,

        style: TextStyle(color: muted, fontSize: 12),

      );

    }

    final selectedExists =

        accreditedPasses.any((item) => item.id == selectedAccreditedPassId);

    final selectedPass = selectedExists

        ? accreditedPasses.firstWhere((item) => item.id == selectedAccreditedPassId)

        : null;

    return SizedBox(

      width: 520,

      child: DropdownButtonFormField<String>(

        key: ValueKey('owned-pass-${selectedAccreditedPassId ?? "none"}'),

        initialValue: selectedExists ? selectedAccreditedPassId : '',

        isExpanded: true,

        decoration: InputDecoration(

          labelText: 'Abono disponible',

          helperText: selectedPass != null && !selectedPass.allowed

              ? 'Este abono no es valido para esta proyeccion.'

              : 'Puedes comprar sin usar abono o seleccionar uno permitido.',

          helperStyle: TextStyle(

            color: selectedPass != null && !selectedPass.allowed ? red : muted,

          ),

          border: const OutlineInputBorder(),

        ),

        items: [

          const DropdownMenuItem(

            value: '',

            child: Text('Sin abono - comprar entrada individual'),

          ),

          ...accreditedPasses.map((pass) {

            return DropdownMenuItem(

              value: pass.id,

              child: Text(

                '${pass.label} - ${pass.allowed ? "permitido" : "no permitido"}',

              ),

            );

          }),

        ],

        onChanged: purchasing

            ? null

            : (value) {

                if (value == null || value.isEmpty) {

                  setState(() {

                    selectedAccreditedPassId = null;

                    message = null;

                    purchaseError = false;

                  });

                  return;

                }

                final pass = accreditedPasses.firstWhere(

                  (item) => item.id == value,

                  orElse: () => const OwnedPass.empty(),

                );

                setState(() {

                  selectedAccreditedPassId = value;

                  if (pass.id.isNotEmpty && !pass.allowed) {

                    purchaseError = true;

                    message =

                        'El abono seleccionado no es valido para esta proyeccion.';

                  } else {

                    message = null;

                  }

                });

              },

      ),

    );

  }



  Widget _confirmation() {

    final price = switch (rate) {

      'Estudiante' => 8,

      'Jubilado' => 7,

      'Acreditado' => 0,

      'VIP' => 0,

      _ => 12,

    };

    final total = price * selectedSeats.length;

    final isSubscription = saleMode == SaleMode.subscription;

    final title = isSubscription

        ? subscriptionType?.name ?? 'Abono'

        : movie?.title ?? 'Entrada';

    final detail = isSubscription

        ? 'Abono para ${attendee?.displayName ?? "persona"}'

        : '${session!.date} - ${session!.time} - ${session!.room}';

    return _centeredPanel(

      CardBox(

        title: 'Venta confirmada',

        subtitle: 'Operacion registrada correctamente',

        accent: isSubscription ? purple : green,

        child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Icon(Icons.check_circle, color: green, size: 54),

          const SizedBox(height: 12),

          Text(

            title,

            style: const TextStyle(

              color: text,

              fontSize: 24,

              fontWeight: FontWeight.w800,

            ),

          ),

          Text(

            detail,

            style: const TextStyle(color: muted),

          ),

          const SizedBox(height: 14),

          if (!isSubscription)

            Text(

              'Asientos: ${selectedSeats.join(", ")}',

              style: const TextStyle(color: text),

            ),

          Text(

            'Persona: ${attendee?.displayName ?? "No seleccionada"}',

            style: const TextStyle(color: text),

          ),

          Text(

            'Pago: ${receipt?.metodoPago ?? paymentMethod} - NIT/CI: ${nit.text.trim().isEmpty ? "S/N" : nit.text.trim()}',

            style: const TextStyle(color: text),

          ),

          if (!isSubscription && selectedAccreditedPassId != null)

            Text(

              'Abono validado: ${_selectedAccreditedPassLabel()}',

              style: const TextStyle(color: text),

            ),

          Text(

            isSubscription

                ? 'Tarifa: $rate - Total: Bs ${(receipt?.montoPagado ?? subscriptionType?.price ?? 0).toStringAsFixed(2)}'

                : 'Tarifa: $rate - Total: Bs ${(receipt?.montoPagado ?? total).toStringAsFixed(2)}',

            style: const TextStyle(

              color: gold,

              fontSize: 18,

              fontWeight: FontWeight.w800,

            ),

          ),

          if (receipt != null) ...[

            Row(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                if (normalizeText(receipt!.metodoPago) == 'qr') ...[

                  GenericQr(label: receipt!.codigoEntrada),

                  const SizedBox(width: 12),

                ],

                Expanded(

                  child: Text(

                    'Codigo: ${receipt!.codigoEntrada}\nFactura: ${receipt!.idFactura}\nMetodo de pago: ${receipt!.metodoPago}',

                    style: const TextStyle(color: muted, fontSize: 12),

                  ),

                ),

              ],

            ),

          ],

          const SizedBox(height: 8),

          const Text(

            'Compra procesada correctamente y validada contra aforo disponible.',

            style: TextStyle(color: green, fontSize: 12),

          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(

            onPressed: () => setState(() {

              step = 1;

              movie = null;

              session = null;

              selectedSeats.clear();

              receipt = null;

              message = null;

            }),

            icon: const Icon(Icons.add),

            label: Text(isSubscription ? 'Nuevo abono' : 'Nueva venta'),

          ),

        ],

        ),

      ),

      maxWidth: 760,

    );

  }



  Future<void> _confirmPurchase() async {

    setState(() {

      purchasing = true;

      message = null;

    });



    try {

      final resolved = await DatabaseGateway.resolveAttendee(

        widget.editionId,

        AttendeeFormData(

          idPersona: selectedPerson?.id ?? attendee?.idPersona ?? '',

          firstName: attendeeName.text.trim(),

          lastName: attendeeLastName.text.trim(),

          email: attendeeEmail.text.trim(),

          phone: attendeePhone.text.trim(),

        ),

      );

      ActiveAccreditation? ensuredAccreditation;

      if (_usesAccreditationRate) {

        final types = widget.accreditationTypes.isEmpty

            ? fallbackAccreditationTypes

            : widget.accreditationTypes;

        final selectedType = types.firstWhere(

          (item) =>

              item.id ==

              (selectedAccreditationTypeId ?? activeAccreditation?.typeId),

          orElse: () => rate == 'VIP'

              ? types.firstWhere(

                  (item) => item.name == 'VIP',

                  orElse: () => types.isEmpty

                      ? const AccreditationType('', '')

                      : types.first,

                )

              : (types.isEmpty ? const AccreditationType('', '') : types.first),

        );

        if (selectedType.id.isEmpty) {

          throw const DatabaseException(

            'ACREDITACION_TIPO_REQUERIDO',

            'Selecciona un tipo de acreditacion para usar esta tarifa.',

          );

        }

        if (rate == 'VIP' && selectedType.name != 'VIP') {

          throw const DatabaseException(

            'ACREDITACION_VIP_REQUERIDA',

            'La tarifa VIP requiere acreditacion VIP activa.',

          );

        }

        ensuredAccreditation = await DatabaseGateway.ensureAccreditation(

          attendee: resolved.attendee,

          selectedType: selectedType,

        );

      }

      if (selectedAccreditedPassId != null) {

        final passes = await DatabaseGateway.fetchAttendeePasses(

          attendeeId: resolved.attendee.id,

          projectionId: session!.idProyeccion,

          subscriptionTypes: widget.subscriptionTypes,

        );

        final selectedPass = passes.firstWhere(

          (pass) => pass.id == selectedAccreditedPassId,

          orElse: () => const OwnedPass.empty(),

        );

        if (selectedPass.id.isNotEmpty && !selectedPass.allowed) {

          throw DatabaseException(

            'ABONO_NO_PERMITIDO',

            'El abono seleccionado no esta permitido para esta proyeccion segun AbonoProyeccion.',

          );

        }

      }

      final response = await DatabaseGateway.p1ComprarEntrada(

        movie: movie!,

        session: session!,

        attendee: resolved.attendee,

        tarifa: selectedAccreditedPassId == null ? rate : 'Acreditado',

        metodoPago: paymentMethod,

        nit: nit.text.trim().isEmpty ? null : nit.text.trim(),

        seats: selectedSeats.toList(),

      );

      if (!mounted) return;

      setState(() {

        purchasing = false;

        purchaseError = false;

        attendee = resolved.attendee;

        activeAccreditation = ensuredAccreditation ?? activeAccreditation;

        if (!widget.attendees.any((item) => item.id == resolved.attendee.id)) {

          widget.attendees.add(resolved.attendee);

        }

        _fillAttendee(resolved.attendee, notify: false);

        try {

          session!.occupied.add(selectedSeats.single);

        } catch (_) {

          // Some fallback demo sessions are const; API-loaded sessions are mutable.

        }

        receipt = response;

        message = null;

        step = 4;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        purchasing = false;

        purchaseError = true;

        message = error.friendlyMessage;

      });

    }

  }



  Future<void> _confirmSubscriptionPurchase() async {

    setState(() {

      purchasing = true;

      message = null;

    });



    try {

      final selectedSubscription =

          subscriptionType ?? _preferredSubscriptionType(widget.subscriptionTypes);

      if (selectedSubscription == null) {

        throw const DatabaseException(

          'API_TIPO_ABONO_NO_ENCONTRADO',

          'No hay tipos de abono disponibles para vender.',

        );

      }

      final resolved = await DatabaseGateway.resolveAttendee(

        widget.editionId,

        AttendeeFormData(

          idPersona: selectedPerson?.id ?? attendee?.idPersona ?? '',

          firstName: attendeeName.text.trim(),

          lastName: attendeeLastName.text.trim(),

          email: attendeeEmail.text.trim(),

          phone: attendeePhone.text.trim(),

        ),

      );

      final response = await DatabaseGateway.venderAbono(

        attendee: resolved.attendee,

        subscriptionType: selectedSubscription,

        tarifa: rate,

        metodoPago: paymentMethod,

        nit: nit.text.trim().isEmpty ? null : nit.text.trim(),

      );

      if (!mounted) return;

      setState(() {

        purchasing = false;

        purchaseError = false;

        attendee = resolved.attendee;

        subscriptionType = selectedSubscription;

        if (!widget.attendees.any((item) => item.id == resolved.attendee.id)) {

          widget.attendees.add(resolved.attendee);

        }

        _fillAttendee(resolved.attendee, notify: false);

        receipt = response;

        message = null;

        step = 4;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        purchasing = false;

        purchaseError = true;

        message = error.friendlyMessage;

      });

    }

  }



  bool get _attendeeFormValid =>

      attendeeName.text.trim().isNotEmpty &&

      attendeeLastName.text.trim().isNotEmpty;



  bool get _usesAccreditationRate => _isAccreditationRate(rate);



  bool _isAccreditationRate(String value) => value == 'Acreditado';



  void _selectTicketRate(String value) {

    setState(() {

      rate = value;

      if (!_isAccreditationRate(value)) {

        selectedAccreditationTypeId = null;

        loadingAccreditation = false;

      }

    });

    if (attendee != null) {

      if (_isAccreditationRate(value)) {

        _loadAttendeeAccreditation(attendee!);

      }

      _loadAccreditedPasses(attendee!);

    }

  }



  Future<void> _loadAccreditedPasses(Attendee item) async {

    if (session == null || item.id.isEmpty) return;

    setState(() => loadingAccreditedPasses = true);

    try {

      final passes = await DatabaseGateway.fetchAttendeePasses(

        attendeeId: item.id,

        projectionId: session!.idProyeccion,

        subscriptionTypes: widget.subscriptionTypes,

      );

      if (!mounted) return;

      setState(() {

        accreditedPasses = passes;

        final currentPassStillExists =

            passes.any((pass) => pass.id == selectedAccreditedPassId);

        if (!currentPassStillExists) {

          final allowedPasses = passes.where((pass) => pass.allowed).toList();

          selectedAccreditedPassId =

              allowedPasses.length == 1 ? allowedPasses.first.id : null;

        }

        loadingAccreditedPasses = false;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        loadingAccreditedPasses = false;

        purchaseError = true;

        message = error.friendlyMessage;

      });

    }

  }



  Future<void> _loadAttendeeAccreditation(Attendee item) async {

    if (!_usesAccreditationRate) return;

    if (item.id.isEmpty) return;

    setState(() => loadingAccreditation = true);

    try {

      final accreditation = await DatabaseGateway.fetchAttendeeAccreditation(

        attendeeId: item.id,

        types: widget.accreditationTypes.isEmpty

            ? fallbackAccreditationTypes

            : widget.accreditationTypes,

      );

      if (!mounted) return;

      if (!_usesAccreditationRate) {

        setState(() => loadingAccreditation = false);

        return;

      }

      setState(() {

        activeAccreditation = accreditation;

        selectedAccreditationTypeId ??= accreditation?.typeId;

        loadingAccreditation = false;

      });

    } on DatabaseException catch (error) {

      if (!mounted) return;

      setState(() {

        loadingAccreditation = false;

        purchaseError = true;

        message = error.friendlyMessage;

      });

    }

  }



  String _selectedAccreditedPassLabel() {

    final id = selectedAccreditedPassId;

    if (id == null) return 'No seleccionado';

    return accreditedPasses

        .firstWhere(

          (pass) => pass.id == id,

          orElse: () => OwnedPass(id, id, 'Abono', 'Activo', allowed: true),

        )

        .label;

  }



  void _markAttendeeDirty() {

    final suggestions = _attendeeSuggestions();

    final match = suggestions.isEmpty ? null : suggestions.first;

    setState(() {

      selectedPerson = match?.person;

      attendee = match?.attendee;

      selectedAccreditedPassId = null;

      accreditedPasses = const [];

      activeAccreditation = null;

      selectedAccreditationTypeId = null;

    });

    if (match?.attendee != null) {

      _loadAttendeeAccreditation(match!.attendee!);

      _loadAccreditedPasses(match.attendee!);

    }

  }



  List<PersonMatch> _attendeeSuggestions() {

    final fullName = normalizeText(

      '${attendeeName.text} ${attendeeLastName.text}',

    );

    final email = attendeeEmail.text.trim().toLowerCase();

    final phone = onlyDigits(attendeePhone.text);



    if (fullName.length < 3 && email.length < 3 && phone.length < 3) {

      return const [];

    }



    final sourcePeople = widget.people.isEmpty

        ? widget.attendees.map((item) => PersonOption.fromAttendee(item)).toList()

        : widget.people;

    final matches = sourcePeople

        .where((item) => _personMatchScore(item, fullName, email, phone) > 0)

        .map((person) => PersonMatch(person, _attendeeForPerson(person)))

        .toList()

      ..sort((a, b) {

        final score = _personMatchScore(b.person, fullName, email, phone)

            .compareTo(_personMatchScore(a.person, fullName, email, phone));

        if (score != 0) return score;

        return a.person.displayName.compareTo(b.person.displayName);

      });

    return matches;

  }



  int _personMatchScore(

    PersonOption item,

    String fullName,

    String email,

    String phone,

  ) {

    var score = 0;

    final candidateName = normalizeText(

      '${item.firstName} ${item.lastName} ${item.displayName}',

    );

    final candidateEmail = item.email.toLowerCase();

    final candidatePhone = onlyDigits(item.phone);



    if (fullName.length >= 3) {

      if (candidateName == fullName) score += 120;

      if (candidateName.contains(fullName) || fullName.contains(candidateName)) {

        score += 100;

      }

      if (fuzzyScore(candidateName, fullName) >= 0.72) score += 80;

    }

    if (email.isNotEmpty && candidateEmail == email) score += 60;

    if (phone.isNotEmpty && candidatePhone == phone) score += 50;

    return score;

  }



  Attendee? _attendeeForPerson(PersonOption person) {

    final personId = person.id;

    final email = person.email.toLowerCase();

    final phone = onlyDigits(person.phone);

    final fullName = normalizeText(person.displayName);

    for (final item in widget.attendees) {

      final samePersonId = personId.isNotEmpty && item.idPersona == personId;

      final sameEmail = email.isNotEmpty && item.email.toLowerCase() == email;

      final samePhone = phone.isNotEmpty && onlyDigits(item.phone) == phone;

      final sameName = fullName.isNotEmpty &&

          normalizeText('${item.firstName} ${item.lastName} ${item.name}') ==

              fullName;

      if (samePersonId || sameEmail || samePhone || sameName) return item;

    }

    return null;

  }



  void _fillPersonMatch(PersonMatch match) {

    attendeeName.text = match.person.firstName.isEmpty

        ? match.person.displayName

        : match.person.firstName;

    attendeeLastName.text = match.person.lastName;

    attendeeEmail.text = match.person.email;

    attendeePhone.text = match.person.phone;

    setState(() {

      selectedPerson = match.person;

      attendee = match.attendee;

      selectedAccreditedPassId = null;

      accreditedPasses = const [];

      activeAccreditation = null;

      selectedAccreditationTypeId = null;

    });

    if (match.attendee != null) {

      _loadAttendeeAccreditation(match.attendee!);

      _loadAccreditedPasses(match.attendee!);

    }

  }





  void _fillAttendee(Attendee item, {bool notify = true}) {

    attendeeName.text = item.firstName.isEmpty ? item.name : item.firstName;

    attendeeLastName.text = item.lastName;

    attendeeEmail.text = item.email;

    attendeePhone.text = item.phone;

    if (notify) {

      setState(() {

        selectedPerson = PersonOption.fromAttendee(item);

        attendee = item;

        selectedAccreditedPassId = null;

        accreditedPasses = const [];

        activeAccreditation = null;

        selectedAccreditationTypeId = null;

      });

      _loadAttendeeAccreditation(item);

      _loadAccreditedPasses(item);

    }

  }



  Attendee? _preferredAttendee(List<Attendee> items) {

    if (items.isEmpty) return null;

    return items.firstWhere(

      (item) => item.id == 'AS005',

      orElse: () => items.first,

    );

  }



  SubscriptionType? _preferredSubscriptionType(List<SubscriptionType> items) {

    if (items.isEmpty) return null;

    return items.firstWhere(

      (item) => item.name == 'Abono Fin de Semana',

      orElse: () => items.first,

    );

  }

}

