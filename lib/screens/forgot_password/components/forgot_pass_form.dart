import 'package:flutter/material.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../components/no_account_text.dart';
import '../../../constants.dart';

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  late Size mediaSize;
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  List<String> errors = [];
  String? email;
  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _phoneInput(phoneController),
          const SizedBox(height: 8),
          FormError(errors: errors),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Do what you want to do
              }
            },
            child: const Text("Continue"),
          ),
          const SizedBox(height: 16),
          const NoAccountText(),
        ],
      ),
    );
  }

  Widget _phoneInput(TextEditingController controller) {
    final prefixText = "+998";

    final prefixStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: mediaSize.width * 0.04,
        color: Colors.black);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 9,
      decoration: InputDecoration(
        labelText: "Telefon",
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixIcon: Icon(Icons.phone),
      ),
    );
  }
}
