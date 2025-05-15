import 'package:flutter/material.dart';

class AssetImageSelector extends StatelessWidget {
  final String initialImage;
  final Function(String) onImageSelected;
  final String? label;

  const AssetImageSelector({
    Key? key,
    required this.initialImage,
    required this.onImageSelected,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: initialImage.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    initialImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showImageUrlDialog(context),
          icon: const Icon(Icons.link),
          label: const Text('Add Image URL'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showImageUrlDialog(BuildContext context) {
    String tempUrl = initialImage;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => tempUrl = value,
          controller: TextEditingController(text: initialImage),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onImageSelected(tempUrl);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
