part of '../main.dart';

const bg = Color(0xfff2efe7);
const surface = Color(0xfffbfaf4);
const surface2 = Color(0xffe9e5dc);
const freshSurface = Color(0xfff5f3ed);
const sidebarBg = Color(0xff050505);
const sidebarPanel = Color(0xff2f2d2b);
const peach = Color(0xffeee9dd);
const burgundy = Color(0xff7c1010);
const slate = Color(0xff6a6661);
const line = Color(0xffa29d95);
const gold = Color(0xff7c1010);
const green = Color(0xff2f2d2b);
const purple = Color(0xff7c1010);
const blue = Color(0xff6a6661);
const red = Color(0xff7c1010);
const text = Color(0xff22201f);
const muted = Color(0xff68645f);
const onDark = Color(0xfff2efe7);
const radiusSm = 8.0;
const radiusMd = 10.0;
const radiusLg = 14.0;

OutlineInputBorder appInputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radiusMd),
    borderSide: BorderSide(color: color, width: width),
  );
}
