import 'package:flutter/material.dart';

class DropdownMenuWidget extends StatefulWidget {
  const DropdownMenuWidget({
    super.key,
    required this.titleList,
    this.defaultMenuItem,
    required this.onValueChanged,
  });

  final List<String> titleList;
  final String? defaultMenuItem;
  final ValueChanged<String?> onValueChanged;

  @override
  State<DropdownMenuWidget> createState() => _DropdownMenuWidgetState();
}

class _DropdownMenuWidgetState extends State<DropdownMenuWidget> {
  String? dropdownValue; // 初始值

  @override
  Widget build(BuildContext context) {
    return Center(
      // width: MediaQuery.of(context).size.width,
      child: DropdownButton(
        value: dropdownValue ?? widget.defaultMenuItem,
        hint: const Text("请选择一个选项"),
        items: widget.titleList.map((e) {
          return DropdownMenuItem<String>(
            value: e,
            child: Center(child: Text(e)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue;
          });
          widget.onValueChanged(newValue);
        },
      ),
    );
  }
}
