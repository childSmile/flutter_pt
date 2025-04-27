import 'package:flutter/material.dart';

class ChooseCommandDialog extends StatefulWidget {
  final List<String> commandList;
  final void Function(List<String>, String) onConfirm;

  const ChooseCommandDialog({
    super.key,
    required this.commandList,
    required this.onConfirm,
  });

  @override
  _ChooseCommandDialogState createState() => _ChooseCommandDialogState();
}

class _ChooseCommandDialogState extends State<ChooseCommandDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('请选择并输入时间间隔'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "请输入内容",
              ),
            ),
            const SizedBox(height: 16),
            // ...widget.commandList.map((title) {
            //   return CheckboxListTile(
            //     title: Text(title),
            //     value: _selectedItems.contains(title),
            //     onChanged: (bool? checked) {
            //       setState(() {
            //         if (checked != null && checked) {
            //           _selectedItems.add(title);
            //         } else {
            //           _selectedItems.remove(title);
            //         }
            //       });
            //     },
            //   );
            // }).toList(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () {
            if (_controller.text.isNotEmpty && _selectedItems.isNotEmpty) {
              // 处理用户输入和选择的内容
              // print("Selected Items: $_selectedItems");
              // print("Input Text: ${_controller.text}");
              widget.onConfirm(_selectedItems, _controller.text);
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CustomSelectionDialog extends StatefulWidget {
  final List<String> items;
  final void Function(Map<String, String?>, bool isLoop) onConfirm;

  const CustomSelectionDialog({
    super.key,
    required this.items,
    required this.onConfirm,
  });

  @override
  _CustomSelectionDialogState createState() => _CustomSelectionDialogState();
}

class _CustomSelectionDialogState extends State<CustomSelectionDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  Map<String, String?> selectedItems = {};
  bool isLoop = false;

  void _toggleSelection(String item) {
    setState(() {
      if (selectedItems.containsKey(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems[item] = "200";
      }
    });
  }

  void _updateInputValue(String item, String value) {
    // print("inputonChanged==$value , $item");
    selectedItems[item] = value;
    // setState(() {
    //   selectedItems[item] = value;
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: 300,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text('选择并输入'),
            Expanded(
              child: CheckboxListTile(
                title: const Text("循环"),
                value: isLoop,
                onChanged: (value) {
                  setState(() {
                    isLoop = !isLoop;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 300,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              // color: Colors.green,
              // width: 150,
              flex: 1,
              child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return CheckboxListTile(
                      value: selectedItems.containsKey(item),
                      title: Text(
                        item.split(":").first,
                        style: const TextStyle(fontSize: 10),
                      ),
                      onChanged: (bool? checked) {
                        if (checked != null) {
                          _toggleSelection(item);
                        }
                      },
                    );
                  }),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              // color: Colors.red,
              // width: 150,
              flex: 1,
              child: ListView.builder(
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems.keys.toList()[index];
                    return Column(
                      children: [
                        Text(item),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(
                                    text: selectedItems[item]),
                                decoration: const InputDecoration(
                                  labelText: "输入间隔时间",
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>
                                    _updateInputValue(item, value),
                                // onSubmitted: (value) {
                                //   print("submit===$value");
                                // },
                              ),
                            ),
                            const Text("ms"),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ), //_buildBodyWidget(),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () {
            // 处理用户选择和输入的内容
            print("Selected Items with Inputs: $selectedItems");
            widget.onConfirm(selectedItems, isLoop);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Row _buildBodyWidget() {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return CheckboxListTile(
                title: Text(item),
                value: selectedItems.containsKey(item),
                onChanged: (bool? checked) {
                  if (checked != null) {
                    _toggleSelection(item);
                  }
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: selectedItems.keys.map((item) {
              return ListTile(
                title: Row(
                  children: [
                    Text(item),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller:
                            TextEditingController(text: selectedItems[item]),
                        decoration: const InputDecoration(
                          labelText: "输入内容",
                        ),
                        onChanged: (value) => _updateInputValue(item, value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _toggleSelection(item),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
