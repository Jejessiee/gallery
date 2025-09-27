import 'package:flutter/material.dart';
import 'models.dart';

class EditorToolbar extends StatelessWidget {
  final DrawMode mode;
  final Color color;
  final double strokeWidth;
  final ValueChanged<DrawMode> onModeChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;

  const EditorToolbar({
    super.key,
    required this.mode,
    required this.color,
    required this.strokeWidth,
    required this.onModeChanged,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownButton<DrawMode>(
              dropdownColor: Colors.black,
              value: mode,
              items: DrawMode.values
                .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e.name,
                    style: const TextStyle(color: Colors.white), // TextStyle
                  ), // Text
                )) // DropdownMenuItem
                .toList(),
              onChanged: (v) => onModeChanged(v!),
          ), //DropdownButton
          IconButton(
              icon: Icon(Icons.color_lens, color: color),
            onPressed: () async {
                final chosen = await showDialog<Color>(
                  context: context,
                  builder: (_) => SimpleDialog(
                    title: const Text("Select Color"),
                    children: [
                      Wrap(
                        children: [
                          for (final c in [
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                            Colors.yellow,
                            Colors.white,
                          ])
                            GestureDetector(
                              onTap: () => Navigator.pop(context, c),
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black),
                                ), // BoxDecoration
                              ), // Container
                            ) // GestureDetector
                        ],
                      ) // Wrap
                    ],
                  ), // SimpleDialog
                );
                if (chosen != null) onColorChanged(chosen);
            },
          ), // IconButton
          Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: strokeWidth,
              activeColor: color,
              onChanged: onStrokeWidthChanged,
          ), // Slider
        ],
      ), // Row
    ); // Container
  }
}