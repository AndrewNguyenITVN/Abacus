import 'package:flutter/material.dart';

enum ColorSelection {
  deepPurple('Tím đậm', Colors.deepPurple),
  purple('Tím', Colors.purple),
  indigo('Chàm', Colors.indigo),
  blue('Xanh dương', Colors.blue),
  teal('Xanh mòng két', Colors.teal),
  green('Xanh lá', Colors.green),
  yellow('Vàng', Colors.yellow),
  orange('Cam', Colors.orange),
  deepOrange('Cam đậm', Colors.deepOrange),
  pink('Hồng', Colors.pink),
  red('Đỏ', Colors.red);

  const ColorSelection(
    this.label,
    this.color,
  );

  final String label;
  final Color color;
}

