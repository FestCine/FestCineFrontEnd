part of '../../main.dart';

class SeatMap extends StatelessWidget {

  const SeatMap({

    super.key,

    required this.occupied,

    required this.selected,

    required this.onTap,

  });



  final List<String> occupied;

  final Set<String> selected;

  final ValueChanged<String> onTap;



  @override

  Widget build(BuildContext context) {

    const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

    return Column(

      children: [

        CustomPaint(size: const Size(420, 28), painter: ScreenPainter()),

        const Text(

          'P A N T A L L A',

          style: TextStyle(color: gold, fontSize: 10, letterSpacing: 3),

        ),

        const SizedBox(height: 16),

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          child: Column(

            children: rows.map((row) {

              return Padding(

                padding: const EdgeInsets.symmetric(vertical: 3),

                child: Row(

                  children: [

                    SizedBox(

                      width: 18,

                      child: Text(row, style: const TextStyle(color: muted)),

                    ),

                    ...List.generate(12, (i) {

                      final id = '$row${i + 1}';

                      final isOcc = occupied.contains(id);

                      final isSel = selected.contains(id);

                      return Padding(

                        padding: EdgeInsets.only(left: i == 6 ? 14 : 5),

                        child: InkWell(

                          onTap: isOcc ? null : () => onTap(id),

                          child: Container(

                            width: 30,

                            height: 30,

                            alignment: Alignment.center,

                            decoration: BoxDecoration(

                              color: isSel

                                  ? gold.withValues(alpha: .22)

                                  : isOcc

                                  ? red.withValues(alpha: .14)

                                  : surface.withValues(alpha: .9),

                              border: Border.all(

                                color: isSel

                                    ? gold

                                    : isOcc

                                    ? red.withValues(alpha: .5)

                                    : line.withValues(alpha: .65),

                                width: 1.4,

                              ),

                              borderRadius: BorderRadius.circular(5),

                            ),

                            child: Text(

                              isSel

                                  ? id

                                  : isOcc

                                  ? 'x'

                                  : '${i + 1}',

                              style: TextStyle(

                                color: isSel

                                    ? gold

                                    : isOcc

                                    ? red

                                    : text.withValues(alpha: .72),

                                fontSize: 10,

                                fontWeight: FontWeight.w700,

                              ),

                            ),

                          ),

                        ),

                      );

                    }),

                    const SizedBox(width: 8),

                    Text(row, style: const TextStyle(color: muted)),

                  ],

                ),

              );

            }).toList(),

          ),

        ),

        const SizedBox(height: 14),

        const Wrap(

          spacing: 14,

          runSpacing: 8,

          children: [

            Legend('Disponible', line, fill: surface),

            Legend('Ocupado', red, mark: 'x'),

            Legend('Seleccionado', gold, fill: Color(0x227c1010)),

          ],

        ),

      ],

    );

  }

}



class ScreenPainter extends CustomPainter {

  @override

  void paint(Canvas canvas, Size size) {

    final paint = Paint()

      ..color = gold

      ..strokeWidth = 3

      ..style = PaintingStyle.stroke;

    final path = Path()

      ..moveTo(20, size.height - 4)

      ..quadraticBezierTo(size.width / 2, 2, size.width - 20, size.height - 4);

    canvas.drawPath(path, paint);

  }



  @override

  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}



class GenericQr extends StatelessWidget {

  const GenericQr({super.key, required this.label});



  final String label;



  @override

  Widget build(BuildContext context) {

    final seed = label.codeUnits.fold<int>(0, (sum, value) => sum + value);

    return Container(

      width: 92,

      height: 92,

      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(

        color: Colors.white,

        border: Border.all(color: line),

        borderRadius: BorderRadius.circular(6),

      ),

      child: GridView.builder(

        physics: const NeverScrollableScrollPhysics(),

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 9,

        ),

        itemCount: 81,

        itemBuilder: (context, index) {

          final row = index ~/ 9;

          final col = index % 9;

          final finder = (row < 3 && col < 3) ||

              (row < 3 && col > 5) ||

              (row > 5 && col < 3);

          final filled = finder || ((index * 31 + seed) % 7 < 3);

          return Container(

            margin: const EdgeInsets.all(.7),

            color: filled ? text : Colors.white,

          );

        },

      ),

    );

  }

}



class Header extends StatelessWidget {

  const Header(this.title, this.subtitle, {super.key, this.trailing});

  final String title;

  final String subtitle;

  final Widget? trailing;



  @override

  Widget build(BuildContext context) {

    return Wrap(

      alignment: WrapAlignment.spaceBetween,

      crossAxisAlignment: WrapCrossAlignment.center,

      runSpacing: 12,

      children: [

        SizedBox(

          width: 620,

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                title,

                style: const TextStyle(

                  color: text,

                  fontSize: 30,

                  fontWeight: FontWeight.w900,

                ),

              ),

              const SizedBox(height: 4),

              Text(subtitle, style: const TextStyle(color: muted)),

            ],

          ),

        ),

        if (trailing != null) trailing!,

      ],

    );

  }

}



class ResponsiveGrid extends StatelessWidget {

  const ResponsiveGrid({

    super.key,

    required this.children,

    this.minWidth = 240,

    this.aspectRatio,

  });

  final List<Widget> children;

  final double minWidth;

  final double? aspectRatio;



  @override

  Widget build(BuildContext context) {

    return LayoutBuilder(

      builder: (context, c) {

        final count = (c.maxWidth / minWidth).floor().clamp(1, 4);

        return GridView.count(

          crossAxisCount: count,

          shrinkWrap: true,

          physics: const NeverScrollableScrollPhysics(),

          mainAxisSpacing: 14,

          crossAxisSpacing: 14,

          childAspectRatio: aspectRatio ?? (count == 1 ? 1.2 : 1.05),

          children: children,

        );

      },

    );

  }

}



class CardBox extends StatelessWidget {

  const CardBox({

    super.key,

    required this.title,

    required this.child,

    this.subtitle,

    this.accent,

  });

  final String title;

  final String? subtitle;

  final Widget child;

  final Color? accent;



  @override

  Widget build(BuildContext context) {

    final tone = accent ?? paletteFor(title);

    final fill = cardFillFor(tone);

    return Container(

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: fill,

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: tone, width: .9),

        boxShadow: [

          BoxShadow(

            color: sidebarBg.withValues(alpha: .08),

            blurRadius: 14,

            offset: const Offset(0, 6),

          ),

        ],

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Container(

            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

            decoration: BoxDecoration(

              color: surface,

              borderRadius: BorderRadius.circular(radiusSm),

              border: Border.all(color: tone, width: 1.1),

            ),

            child: Row(

              children: [

                Container(

                  width: 4,

                  height: 22,

                  decoration: BoxDecoration(

                    color: tone,

                    borderRadius: BorderRadius.circular(8),

                  ),

                ),

                const SizedBox(width: 8),

                Expanded(

                  child: Text(

                    title,

                    style: const TextStyle(

                      color: text,

                      fontSize: 15,

                      fontWeight: FontWeight.w900,

                    ),

                  ),

                ),

              ],

            ),

          ),

          if (subtitle != null)

            Padding(

              padding: const EdgeInsets.only(top: 3),

              child: Text(

                subtitle!,

                style: const TextStyle(color: muted, fontSize: 12),

              ),

            ),

          const SizedBox(height: 14),

          child,

        ],

      ),

    );

  }

}



class StatCard extends StatelessWidget {

  const StatCard(

    this.label,

    this.value,

    this.sub,

    this.icon,

    this.color, {

    super.key,

    this.trend,

  });

  final String label;

  final String value;

  final String sub;

  final IconData icon;

  final Color color;

  final int? trend;



  @override

  Widget build(BuildContext context) {

    return CardBox(

      title: label.toUpperCase(),

      accent: color,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              BadgeIcon(icon, color, compact: true),

              const Spacer(),

              if (trend != null)

                Text('+$trend%', style: const TextStyle(color: green)),

            ],

          ),

          const SizedBox(height: 12),

          SizedBox(

            width: double.infinity,

            child: FittedBox(

              alignment: Alignment.centerLeft,

              fit: BoxFit.scaleDown,

              child: Text(

                value,

                maxLines: 2,

                style: const TextStyle(

                  color: text,

                  fontSize: 28,

                  fontWeight: FontWeight.w900,

                ),

              ),

            ),

          ),

          Text(sub, style: const TextStyle(color: muted, fontSize: 12)),

        ],

      ),

    );

  }

}



class BadgeIcon extends StatelessWidget {

  const BadgeIcon(

    this.icon,

    this.color, {

    super.key,

    this.compact = false,

    this.background,

    this.borderColor,

  });

  final IconData icon;

  final Color color;

  final bool compact;

  final Color? background;

  final Color? borderColor;

  @override

  Widget build(BuildContext context) => Container(

    width: compact ? 34 : 40,

    height: compact ? 34 : 40,

    decoration: BoxDecoration(

      color:

          background ??

          (color == Colors.white ? Colors.white24 : cardFillFor(color)),

      borderRadius: BorderRadius.circular(10),

      border: Border.all(

        color: borderColor ?? (color == Colors.white ? Colors.white : color),

      ),

    ),

    child: Icon(icon, color: color, size: compact ? 18 : 22),

  );

}



class Pill extends StatelessWidget {

  const Pill(this.textValue, {super.key, this.color = gold});

  final String textValue;

  final Color color;

  @override

  Widget build(BuildContext context) => Container(

    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),

    decoration: BoxDecoration(

      color: surface,

      borderRadius: BorderRadius.circular(radiusSm),

      border: Border.all(color: color, width: 1.2),

      boxShadow: [

        BoxShadow(

          color: sidebarBg.withValues(alpha: .05),

          blurRadius: 8,

          offset: const Offset(0, 3),

        ),

      ],

    ),

    child: Text(

      textValue,

      style: TextStyle(

        color: color,

        fontSize: 11,

        fontWeight: FontWeight.w900,

        letterSpacing: .3,

      ),

    ),

  );

}



class StatusChip extends StatelessWidget {

  const StatusChip(this.label, this.color, {super.key});

  final String label;

  final Color color;

  @override

  Widget build(BuildContext context) => Container(

    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),

    decoration: BoxDecoration(

      color: surface,

      borderRadius: BorderRadius.circular(radiusMd),

      border: Border.all(color: color, width: 1.1),

      boxShadow: [

        BoxShadow(

          color: sidebarBg.withValues(alpha: .04),

          blurRadius: 8,

          offset: const Offset(0, 3),

        ),

      ],

    ),

    child: Row(

      mainAxisSize: MainAxisSize.min,

      children: [

        Icon(Icons.circle, size: 9, color: color),

        const SizedBox(width: 8),

        Text(label, style: const TextStyle(color: text, fontSize: 12)),

      ],

    ),

  );

}



class InfoBox extends StatelessWidget {

  const InfoBox({

    super.key,

    required this.title,

    required this.body,

    required this.footer,

    required this.icon,

    required this.color,

  });

  final String title;

  final String body;

  final String footer;

  final IconData icon;

  final Color color;

  @override

  Widget build(BuildContext context) => Container(

    padding: const EdgeInsets.all(14),

    decoration: BoxDecoration(

      color: sidebarPanel,

      borderRadius: BorderRadius.circular(14),

      border: Border.all(color: peach),

    ),

    child: Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(

          title,

          style: const TextStyle(color: peach, fontSize: 11, letterSpacing: 1),

        ),

        const SizedBox(height: 6),

        Text(

          body,

          maxLines: 2,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(color: onDark, fontWeight: FontWeight.w700),

        ),

        const SizedBox(height: 6),

        Row(

          children: [

            Icon(icon, color: color, size: 10),

            const SizedBox(width: 6),

            Expanded(

              child: Text(

                footer,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(color: color, fontSize: 12),

              ),

            ),

          ],

        ),

      ],

    ),

  );

}



class ProgressRow extends StatelessWidget {

  const ProgressRow(

    this.label,

    this.percent,

    this.color, {

    super.key,

    this.compact = false,

  });

  final String label;

  final int percent;

  final Color color;

  final bool compact;

  @override

  Widget build(BuildContext context) => Padding(

    padding: EdgeInsets.only(bottom: compact ? 6 : 12),

    child: Column(

      children: [

        Row(

          children: [

            Expanded(

              child: Text(

                label,

                maxLines: compact ? 1 : 2,

                overflow: TextOverflow.ellipsis,

                style: TextStyle(color: text, fontSize: compact ? 11.5 : 13),

              ),

            ),

            Text(

              '$percent%',

              style: TextStyle(color: color, fontWeight: FontWeight.w800),

            ),

          ],

        ),

        SizedBox(height: compact ? 3 : 6),

        ClipRRect(

          borderRadius: BorderRadius.circular(10),

          child: LinearProgressIndicator(

            value: percent.clamp(0, 100) / 100,

            minHeight: compact ? 5 : 7,

            color: color,

            backgroundColor: surface2,

          ),

        ),

      ],

    ),

  );

}



class EmptyState extends StatelessWidget {

  const EmptyState({super.key, required this.icon, required this.text});



  final IconData icon;

  final String text;



  @override

  Widget build(BuildContext context) => Container(

    width: double.infinity,

    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(

      color: surface,

      borderRadius: BorderRadius.circular(radiusMd),

      border: Border.all(color: line),

    ),

    child: Row(

      children: [

        Icon(icon, color: muted),

        const SizedBox(width: 10),

        Expanded(

          child: Text(

            text,

            style: const TextStyle(color: muted, fontWeight: FontWeight.w700),

          ),

        ),

      ],

    ),

  );

}



class StepperPills extends StatelessWidget {

  const StepperPills(this.step, {super.key});

  final int step;

  @override

  Widget build(BuildContext context) => Wrap(

    spacing: 8,

    children: ['Cartelera', 'Horarios', 'Asientos', 'Confirmacion']

        .asMap()

        .entries

        .map(

          (e) => Pill(

            '${e.key + 1}. ${e.value}',

            color: e.key + 1 <= step ? gold : muted,

          ),

        )

        .toList(),

  );

}



class MovieCard extends StatelessWidget {

  const MovieCard({super.key, required this.movie, required this.onTap});

  final Movie movie;

  final VoidCallback onTap;

  @override

  Widget build(BuildContext context) => InkWell(

    onTap: onTap,

    borderRadius: BorderRadius.circular(14),

    child: CardBox(

      title: movie.title,

      subtitle:

          '${movie.country} - ${movie.genre} - ${movie.duration} min - ${movie.rating}',

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          ClipRRect(

            borderRadius: BorderRadius.circular(10),

            child: AspectRatio(

              aspectRatio: 16 / 10,

              child: Image.network(

                movie.posterUrl,

                fit: BoxFit.cover,

                errorBuilder: (_, _, _) => Container(

                  color: surface2,

                  child: const Center(

                    child: Icon(

                      Icons.movie_creation_outlined,

                      color: red,

                      size: 44,

                    ),

                  ),

                ),

              ),

            ),

          ),

          const SizedBox(height: 12),

          Text(

            movie.synopsis,

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(color: muted, height: 1.35),

          ),

          if (movie.director.isNotEmpty || movie.format.isNotEmpty) ...[

            const SizedBox(height: 8),

            Text(

              [

                if (movie.director.isNotEmpty) 'Director: ${movie.director}',

                if (movie.format.isNotEmpty) 'Formato: ${movie.format}',

              ].join(' - '),

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(color: text, fontSize: 12),

            ),

          ],

          const SizedBox(height: 10),

          const Align(

            alignment: Alignment.centerRight,

            child: Icon(Icons.chevron_right, color: red),

          ),

        ],

      ),

    ),

  );

}



class ActionCard extends StatelessWidget {

  const ActionCard({

    super.key,

    required this.icon,

    required this.title,

    required this.subtitle,

    required this.footer,

    required this.color,

    required this.onTap,

  });

  final IconData icon;

  final String title;

  final String subtitle;

  final String footer;

  final Color color;

  final VoidCallback onTap;

  @override

  Widget build(BuildContext context) => InkWell(

    onTap: onTap,

    borderRadius: BorderRadius.circular(14),

    child: CardBox(

      title: title,

      subtitle: subtitle,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          BadgeIcon(icon, color, compact: true),

          const SizedBox(height: 8),

          Text(

            footer,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(color: muted, height: 1.2),

          ),

        ],

      ),

    ),

  );

}



class BackLine extends StatelessWidget {

  const BackLine(this.label, this.onBack, {super.key});

  final String label;

  final VoidCallback onBack;

  @override

  Widget build(BuildContext context) => Row(

    children: [

      OutlinedButton.icon(

        onPressed: onBack,

        icon: const Icon(Icons.chevron_left),

        label: const Text('Volver'),

      ),

      const SizedBox(width: 12),

      Expanded(

        child: Text(

          label,

          style: const TextStyle(color: text, fontWeight: FontWeight.w700),

        ),

      ),

    ],

  );

}



class RemovableChip extends StatefulWidget {

  const RemovableChip({super.key, required this.label, required this.onDeleted});



  final String label;

  final VoidCallback onDeleted;



  @override

  State<RemovableChip> createState() => _RemovableChipState();

}



class _RemovableChipState extends State<RemovableChip> {

  bool hovering = false;



  @override

  Widget build(BuildContext context) {

    return MouseRegion(

      onEnter: (_) => setState(() => hovering = true),

      onExit: (_) => setState(() => hovering = false),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 140),

        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

        decoration: BoxDecoration(

          color: hovering ? surface2 : surface,

          borderRadius: BorderRadius.circular(radiusSm),

          border: Border.all(color: hovering ? burgundy : line),

        ),

        child: Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            ConstrainedBox(

              constraints: const BoxConstraints(maxWidth: 210),

              child: Text(

                widget.label,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(

                  color: text,

                  fontSize: 12,

                  fontWeight: FontWeight.w800,

                ),

              ),

            ),

            const SizedBox(width: 6),

            Opacity(

              opacity: hovering ? 1 : 0,

              child: InkWell(

                borderRadius: BorderRadius.circular(16),

                onTap: hovering ? widget.onDeleted : null,

                child: const SizedBox(

                  width: 16,

                  height: 16,

                  child: Icon(Icons.close, size: 15, color: burgundy),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}



class CategoryPickerDialog extends StatefulWidget {

  const CategoryPickerDialog({super.key, required this.options});



  final List<CategoryOption> options;



  @override

  State<CategoryPickerDialog> createState() => _CategoryPickerDialogState();

}



class _CategoryPickerDialogState extends State<CategoryPickerDialog> {

  final name = TextEditingController();

  final description = TextEditingController();

  CategoryOption? selected;



  @override

  void dispose() {

    name.dispose();

    description.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    final query = normalizeText(name.text);

    final matches = widget.options

        .where((item) => query.isEmpty || normalizeText(item.name).contains(query))

        .take(8)

        .toList();

    return AlertDialog(

      title: const Text('Agregar categoria'),

      content: SizedBox(

        width: 460,

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(

              controller: name,

              autofocus: true,

              decoration: const InputDecoration(

                labelText: 'Buscar o escribir categoria',

                prefixIcon: Icon(Icons.search),

              ),

              onChanged: (_) => setState(() => selected = null),

            ),

            const SizedBox(height: 10),

            TextField(

              controller: description,

              decoration: const InputDecoration(

                labelText: 'Descripcion',

                helperText: 'Opcional para categorias nuevas',

              ),

            ),

            const SizedBox(height: 10),

            SizedBox(

              height: 220,

              child: ListView(

                children: matches.map((item) {

                  final active = selected?.id == item.id;

                  return ListTile(

                    dense: true,

                    selected: active,

                    leading: Icon(

                      active ? Icons.check_circle : Icons.emoji_events_outlined,

                      color: active ? burgundy : slate,

                    ),

                    title: Text(item.name),

                    subtitle: item.description.isEmpty

                        ? null

                        : Text(item.description),

                    onTap: () => setState(() {

                      selected = item;

                      name.text = item.name;

                      description.text = item.description;

                    }),

                  );

                }).toList(),

              ),

            ),

          ],

        ),

      ),

      actions: [

        TextButton(

          onPressed: () => Navigator.pop(context),

          child: const Text('Cancelar'),

        ),

        FilledButton.icon(

          onPressed: name.text.trim().isEmpty

              ? null

              : () {

                  final option = selected ??

                      CategoryOption(

                        newLocalId('CC'),

                        toTitleCase(name.text),

                        description: description.text.trim(),

                      );

                  Navigator.pop(context, option);

                },

          icon: const Icon(Icons.add),

          label: const Text('Agregar'),

        ),

      ],

    );

  }

}



class GenrePickerDialog extends StatefulWidget {

  const GenrePickerDialog({super.key, required this.options});



  final List<GenreOption> options;



  @override

  State<GenrePickerDialog> createState() => _GenrePickerDialogState();

}



class _GenrePickerDialogState extends State<GenrePickerDialog> {

  final name = TextEditingController();

  GenreOption? selected;



  @override

  void dispose() {

    name.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    final query = normalizeText(name.text);

    final matches = widget.options

        .where((item) => query.isEmpty || normalizeText(item.name).contains(query))

        .take(8)

        .toList();

    return AlertDialog(

      title: const Text('Agregar genero'),

      content: SizedBox(

        width: 420,

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(

              controller: name,

              autofocus: true,

              decoration: const InputDecoration(

                labelText: 'Buscar o escribir genero',

                prefixIcon: Icon(Icons.search),

              ),

              onChanged: (_) => setState(() => selected = null),

            ),

            const SizedBox(height: 10),

            SizedBox(

              height: 220,

              child: ListView(

                children: matches.map((item) {

                  final active = selected?.name == item.name;

                  return ListTile(

                    dense: true,

                    selected: active,

                    leading: Icon(

                      active ? Icons.check_circle : Icons.movie_filter_outlined,

                      color: active ? burgundy : slate,

                    ),

                    title: Text(item.name),

                    onTap: () => setState(() {

                      selected = item;

                      name.text = item.name;

                    }),

                  );

                }).toList(),

              ),

            ),

          ],

        ),

      ),

      actions: [

        TextButton(

          onPressed: () => Navigator.pop(context),

          child: const Text('Cancelar'),

        ),

        FilledButton.icon(

          onPressed: name.text.trim().isEmpty && selected == null

              ? null

              : () => Navigator.pop(

                    context,

                    selected ??

                        GenreOption(newLocalId('GE'), toTitleCase(name.text)),

                  ),

          icon: const Icon(Icons.add),

          label: const Text('Agregar'),

        ),

      ],

    );

  }

}



class DirectorFormDialog extends StatefulWidget {

  const DirectorFormDialog({super.key, required this.people});



  final List<PersonOption> people;



  @override

  State<DirectorFormDialog> createState() => _DirectorFormDialogState();

}



class _DirectorFormDialogState extends State<DirectorFormDialog> {

  final name = TextEditingController();

  final phone = TextEditingController();

  final country = TextEditingController(text: 'Bolivia');

  final bio = TextEditingController();

  PersonOption? selectedPerson;



  @override

  void dispose() {

    name.dispose();

    phone.dispose();

    country.dispose();

    bio.dispose();

    super.dispose();

  }



  List<PersonOption> _suggestions() {

    final query = normalizeText(name.text);

    final phoneQuery = onlyDigits(phone.text);

    if (query.length < 3 && phoneQuery.length < 3) return const [];

    final matches = widget.people.where((item) {

      final candidateName = normalizeText(item.displayName);

      final candidatePhone = onlyDigits(item.phone);

      final nameMatches = query.length >= 3 &&

          (candidateName == query ||

              candidateName.contains(query) ||

              query.contains(candidateName) ||

              fuzzyScore(candidateName, query) >= 0.72);

      final phoneMatches =

          phoneQuery.length >= 3 && candidatePhone.contains(phoneQuery);

      return nameMatches || phoneMatches;

    }).toList()

      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return matches.take(5).toList();

  }



  void _fillPerson(PersonOption person) {

    setState(() {

      selectedPerson = person;

      name.text = person.displayName;

      if (person.phone.trim().isNotEmpty) phone.text = person.phone;

    });

  }



  Widget _personMatches() {

    final matches = _suggestions();

    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const SizedBox(height: 8),

        Text(

          'Personas encontradas',

          style: TextStyle(

            color: muted,

            fontWeight: FontWeight.w700,

            fontSize: 12,

          ),

        ),

        const SizedBox(height: 6),

        Wrap(

          spacing: 8,

          runSpacing: 8,

          children: matches.map((person) {

            final selected = selectedPerson?.id == person.id;

            final detail = [

              person.id,

              if (person.phone.trim().isNotEmpty) person.phone,

            ].where((part) => part.trim().isNotEmpty).join(' - ');

            return ActionChip(

              avatar: Icon(

                selected

                    ? Icons.check_circle_outline

                    : Icons.person_search_outlined,

                size: 18,

              ),

              label: Text(

                detail.isEmpty

                    ? 'Usar ${person.displayName}'

                    : 'Usar ${person.displayName} ($detail)',

              ),

              onPressed: () => _fillPerson(person),

            );

          }).toList(),

        ),

      ],

    );

  }



  @override

  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text('Registrar director'),

      content: SizedBox(

        width: 420,

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(

              controller: name,

              autofocus: true,

              decoration: const InputDecoration(labelText: 'Nombre completo'),

              onChanged: (_) => setState(() => selectedPerson = null),

            ),

            _personMatches(),

            const SizedBox(height: 10),

            TextField(

              controller: phone,

              keyboardType: TextInputType.phone,

              decoration: const InputDecoration(labelText: 'Nro telefono'),

              onChanged: (_) => setState(() {}),

            ),

            const SizedBox(height: 10),

            TextField(

              controller: country,

              decoration: const InputDecoration(labelText: 'Pais'),

            ),

            const SizedBox(height: 10),

            TextField(

              controller: bio,

              minLines: 2,

              maxLines: 3,

              decoration: const InputDecoration(labelText: 'Biografia'),

            ),

          ],

        ),

      ),

      actions: [

        TextButton(

          onPressed: () => Navigator.pop(context),

          child: const Text('Cancelar'),

        ),

        FilledButton.icon(

          onPressed: name.text.trim().isEmpty

              ? null

              : () => Navigator.pop(

                    context,

                    DirectorOption(

                      newLocalId('PC'),

                      toTitleCase(name.text),

                      country: country.text.trim(),

                      biography: bio.text.trim(),

                      phone: phone.text.trim(),

                    ),

                  ),

          icon: const Icon(Icons.person_add_alt_1_outlined),

          label: const Text('Registrar'),

        ),

      ],

    );

  }

}



class JuryFormDialog extends StatefulWidget {

  const JuryFormDialog({super.key});



  @override

  State<JuryFormDialog> createState() => _JuryFormDialogState();

}



class _JuryFormDialogState extends State<JuryFormDialog> {

  final firstName = TextEditingController();

  final lastName = TextEditingController();

  final email = TextEditingController();

  final phone = TextEditingController();

  final specialty = TextEditingController();

  String estado = 'Pendiente';

  String tipo = 'Experto';



  @override

  void dispose() {

    firstName.dispose();

    lastName.dispose();

    email.dispose();

    phone.dispose();

    specialty.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text('Nuevo jurado'),

      content: SizedBox(

        width: 520,

        child: Wrap(

          spacing: 10,

          runSpacing: 10,

          children: [

            SizedBox(

              width: 240,

              child: TextField(

                controller: firstName,

                autofocus: true,

                decoration: const InputDecoration(labelText: 'Nombre'),

                onChanged: (_) => setState(() {}),

              ),

            ),

            SizedBox(

              width: 240,

              child: TextField(

                controller: lastName,

                decoration: const InputDecoration(labelText: 'Apellido'),

                onChanged: (_) => setState(() {}),

              ),

            ),

            SizedBox(

              width: 240,

              child: TextField(

                controller: email,

                decoration: const InputDecoration(labelText: 'Correo'),

                onChanged: (_) => setState(() {}),

              ),

            ),

            SizedBox(

              width: 240,

              child: TextField(

                controller: phone,

                decoration: const InputDecoration(labelText: 'Telefono'),

              ),

            ),

            SizedBox(

              width: 240,

              child: DropdownButtonFormField<String>(

                initialValue: estado,

                decoration: const InputDecoration(labelText: 'Estado asistencia'),

                items: const ['Presente', 'Ausente', 'Pendiente']

                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))

                    .toList(),

                onChanged: (value) => setState(() => estado = value ?? estado),

              ),

            ),

            SizedBox(

              width: 240,

              child: DropdownButtonFormField<String>(

                initialValue: tipo,

                decoration: const InputDecoration(labelText: 'Tipo jurado'),

                items: const ['Experto', 'Critico', 'Director', 'Productor']

                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))

                    .toList(),

                onChanged: (value) => setState(() => tipo = value ?? tipo),

              ),

            ),

            SizedBox(

              width: 490,

              child: TextField(

                controller: specialty,

                decoration: const InputDecoration(labelText: 'Especialidad'),

              ),

            ),

          ],

        ),

      ),

      actions: [

        TextButton(

          onPressed: () => Navigator.pop(context),

          child: const Text('Cancelar'),

        ),

        FilledButton.icon(

          onPressed: firstName.text.trim().isEmpty ||

                  lastName.text.trim().isEmpty ||

                  email.text.trim().isEmpty

              ? null

              : () => Navigator.pop(

                    context,

                    JuryDraft(

                      firstName: firstName.text.trim(),

                      lastName: lastName.text.trim(),

                      email: email.text.trim(),

                      phone: phone.text.trim(),

                      estadoAsistencia: estado,

                      especialidad: specialty.text.trim(),

                      tipoJurado: tipo,

                    ),

                  ),

          icon: const Icon(Icons.person_add_alt_1_outlined),

          label: const Text('Crear jurado'),

        ),

      ],

    );

  }

}



class Legend extends StatelessWidget {

  const Legend(this.label, this.color, {super.key, this.fill, this.mark});

  final String label;

  final Color color;

  final Color? fill;

  final String? mark;

  @override

  Widget build(BuildContext context) => Row(

    mainAxisSize: MainAxisSize.min,

    children: [

      Container(

        width: 14,

        height: 14,

        decoration: BoxDecoration(

          border: Border.all(color: color),

          borderRadius: BorderRadius.circular(4),

          color: fill ?? color.withValues(alpha: .14),

        ),

        alignment: Alignment.center,

        child: mark == null

            ? null

            : Text(

                mark!,

                style: TextStyle(

                  color: color,

                  fontSize: 10,

                  fontWeight: FontWeight.w900,

                ),

              ),

        ),

      const SizedBox(width: 6),

      Text(label, style: const TextStyle(color: muted, fontSize: 12)),

    ],

  );

}



class AlertBanner extends StatelessWidget {

  const AlertBanner(

    this.message,

    this.color, {

    super.key,

    required this.onClose,

  });

  final String message;

  final Color color;

  final VoidCallback onClose;

  @override

  Widget build(BuildContext context) {

    final isError = color == red;

    return Container(

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: isError ? surface2 : freshSurface,

        border: Border.all(color: isError ? red : sidebarBg),

        borderRadius: BorderRadius.circular(12),

      ),

      child: Row(

        children: [

          Icon(isError ? Icons.error_outline : Icons.info_outline, color: color),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              message,

              style: const TextStyle(color: text, fontWeight: FontWeight.w600),

            ),

          ),

          IconButton(

            onPressed: onClose,

            icon: const Icon(Icons.close, color: sidebarBg),

          ),

        ],

      ),

    );

  }

}



class SelectLine extends StatelessWidget {

  const SelectLine(

    this.label,

    this.value,

    this.items,

    this.onChanged, {

    super.key,

  });

  final String label;

  final String value;

  final List<String> items;

  final ValueChanged<String> onChanged;

  @override

  Widget build(BuildContext context) => Padding(

    padding: const EdgeInsets.only(bottom: 12),

    child: DropdownButtonFormField<String>(

      initialValue: value,

      isExpanded: true,

      dropdownColor: surface,

      decoration: InputDecoration(labelText: label),

      items: items

          .map((i) => DropdownMenuItem(value: i, child: Text(i)))

          .toList(),

      onChanged: (v) {

        if (v != null) onChanged(v);

      },

    ),

  );

}

