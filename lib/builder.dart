import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:icon_class_generator/src/icon_font_generator.dart';

// Builder iconFontBuilder(BuilderOptions options) =>
//     LibraryBuilder(IconFontGenerator());
Builder iconFontBuilder(BuilderOptions options) =>
    LibraryBuilder(IconFontGenerator());
