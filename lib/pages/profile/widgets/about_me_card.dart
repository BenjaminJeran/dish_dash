import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart';

class AboutMeCard extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;

  const AboutMeCard({super.key, required this.text, required this.onChanged});

  @override
  State<AboutMeCard> createState() => _AboutMeCardState();
}

class _AboutMeCardState extends State<AboutMeCard> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant AboutMeCard oldWidget) {
    if (oldWidget.text != widget.text && !_isEditing) {
      _controller.text = widget.text;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
    if (!_isEditing) widget.onChanged(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'O meni',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: _toggleEdit,
                ),
              ],
            ),
            _isEditing
                ? TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Vnesi nekaj o sebi...',
                  ),
                )
                : Text(widget.text, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
