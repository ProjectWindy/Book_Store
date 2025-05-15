import 'package:flutter/material.dart';

class VoucherInput extends StatefulWidget {
  final Function(String) onApply;
  final bool isLoading;

  const VoucherInput({
    Key? key,
    required this.onApply,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<VoucherInput> createState() => _VoucherInputState();
}

class _VoucherInputState extends State<VoucherInput> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Nhập mã giảm giá',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mã giảm giá';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: widget.isLoading
                ? null
                : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      widget.onApply(_controller.text);
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}
