import 'package:flutter/material.dart';

class EditableTextField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final TextStyle? style;

  const EditableTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.style,
  });

  @override
  State<EditableTextField> createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant EditableTextField oldWidget) {
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) widget.onChanged(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isEditing
                ? Flexible(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: widget.style,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                : Text(widget.value, style: widget.style),
            const SizedBox(width: 6),
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _toggleEdit,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
