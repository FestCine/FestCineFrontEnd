part of '../main.dart';

class FestCineApp extends StatelessWidget {
  const FestCineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FestCine',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.light,
          primary: gold,
          secondary: peach,
          tertiary: burgundy,
          surface: surface,
        ),
        fontFamily: 'Arial',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: const TextStyle(color: burgundy),
          floatingLabelStyle: const TextStyle(
            color: gold,
            fontWeight: FontWeight.w800,
          ),
          helperStyle: const TextStyle(color: muted),
          errorStyle: const TextStyle(color: red, fontWeight: FontWeight.w700),
          border: appInputBorder(line),
          enabledBorder: appInputBorder(line),
          focusedBorder: appInputBorder(gold, width: 1.7),
          errorBorder: appInputBorder(red, width: 1.4),
          focusedErrorBorder: appInputBorder(red, width: 1.8),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: gold,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            side: const BorderSide(color: gold, width: 1.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: freshSurface,
          selectedColor: surface2,
          disabledColor: freshSurface,
          checkmarkColor: gold,
          labelStyle: const TextStyle(color: text, fontWeight: FontWeight.w700),
          secondaryLabelStyle:
              const TextStyle(color: text, fontWeight: FontWeight.w700),
          side: const BorderSide(color: line, width: 1.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        checkboxTheme: CheckboxThemeData(
          side: const BorderSide(color: slate, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.all(line),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return BorderSide(
                color: selected ? gold : line,
                width: selected ? 1.5 : 1,
              );
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? surface2
                  : surface;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? gold : text;
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMd),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.hovered)
                  ? surface2
                  : Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.all(sidebarBg),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMd),
              ),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.hovered)
                  ? const BorderSide(color: line)
                  : BorderSide.none;
            }),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
