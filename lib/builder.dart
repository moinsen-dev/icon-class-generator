import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:together_icons/src/icon_font_generator.dart';

Builder iconFontBuilder(BuilderOptions options) =>
    LibraryBuilder(IconFontGenerator());
