import 'package:build/build.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class IconFontGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final nameRegEx = new RegExp(r'(.*)\.icg');
    final pathSegment = buildStep.inputId.pathSegments;
    // final lastSegment = pathSegment[pathSegment.l]
    final name = nameRegEx.firstMatch(pathSegment.last)?.group(1)?.trim() ?? '';
    print(
        'Name: $name, Path: ${buildStep.inputId.path}, Path: ${buildStep.inputId.pathSegments}');
    final fontName = transformToCamelCase(name);

    String contents = await buildStep.readAsString(buildStep.inputId);

    final staticIconRegEx =
        RegExp(r'static\sconst\sIconData.*[\n\r]*.*?;', multiLine: true);

    final className = "Icg${fontName.pascalCase}";

    final newIcons = staticIconRegEx
        .allMatches(contents)
        .map((e) =>
            renderIconFunc(e.group(0) ?? '', fontName.pascalCase, className))
        .join();

    return """
import 'package:flutter/material.dart';
import 'package:icon_class_generator/icons/$name.icg.dart';

class $className extends Icon {
  /// General constructor
  /// Not intended to be used widely, but who knows. It may come at hand sometime
  $className(
    IconData icon, {
    Key? key,
    double? size,
    Color? color,
    String? semanticLabel,
    TextDirection? textDirection,
  }) : super(
          icon,
          key: key,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
          textDirection: textDirection,
        );

  $newIcons

  }

    """;
  }

  String transformToCamelCase(String fontName) {
    ReCase res = new ReCase(fontName);

    return res.camelCase;
  }

  String renderIconFunc(String match, String fontName, String className) {
    if (match.isEmpty) {
      return '';
    }

    final iconRegEx = RegExp(r'static const IconData (.*) =');
    final iconName = iconRegEx.firstMatch(match)?.group(1)?.trim() ?? '';

    final newIconName = transformToCamelCase(iconName.replaceAll('__', 'X'));

    return """
      $className.$newIconName({
          Key? key,
          double? size,
          Color? color,
          String? semanticLabel,
          TextDirection? textDirection,
        }) : super(
                $fontName.$iconName,
                key: key,
                size: size,
                color: color,
                semanticLabel: semanticLabel,
                textDirection: textDirection,
              );
    """;
  }
}
