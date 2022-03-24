import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';
import 'package:together_icons/src/together_icons_annotation.dart';

class IconFontGenerator extends GeneratorForAnnotation<TogetherIcons1> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // TODO: add here: ${annotation.read('name')}
    final name = 'icon_8';
    final fontName = transformToCamelCase(name);

    String contents = new File('./lib/icons/${name}.dart').readAsStringSync();

    final staticIconRegEx =
        RegExp(r'static\sconst\sIconData.*[\n\r]*.*?;', multiLine: true);

    final className = "Together${fontName.pascalCase}";

    final newIcons = staticIconRegEx
        .allMatches(contents)
        .map((e) =>
            renderIconFunc(e.group(0) ?? '', fontName.pascalCase, className))
        .join();

    return """
import 'package:flutter/material.dart';
import 'package:together_icons/icons/${name}.dart';

class ${className} extends Icon {
  /// General constructor
  /// Not intended to be used widely, but who knows. It may come at hand sometime
  ${className}(
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

  ${newIcons}

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
      ${className}.${newIconName}({
          Key? key,
          double? size,
          Color? color,
          String? semanticLabel,
          TextDirection? textDirection,
        }) : super(
                ${fontName}.${iconName},
                key: key,
                size: size,
                color: color,
                semanticLabel: semanticLabel,
                textDirection: textDirection,
              );
    """;
  }
}
