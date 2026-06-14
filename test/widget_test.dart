// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:festcine_app/main.dart';

void main() {
  testWidgets('FestCine dashboard smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FestCineApp());
    await tester.tap(find.text('Ingresar como Cajero'));
    await tester.pumpAndSettle();

    expect(find.text('FestCine'), findsWidgets);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Bienvenido, FestCine XII'), findsOneWidget);
  });

  testWidgets('navigates to box office', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FestCineApp());
    await tester.tap(find.text('Ingresar como Cajero'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Taquilla').first);
    await tester.pump();

    expect(
      find.text('Venta guiada de entradas para FestCine XII'),
      findsOneWidget,
    );
    expect(find.text('El Ultimo Fotograma'), findsOneWidget);
  });

  testWidgets('admin can access agenda module', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FestCineApp());
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingresar como Administrador'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Control de Agenda').first);
    await tester.pump();

    expect(
      find.text('Programacion de salas con validacion de conflictos'),
      findsOneWidget,
    );
    expect(find.text('Programar funcion'), findsOneWidget);
  });
}
