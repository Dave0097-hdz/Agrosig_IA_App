import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/theme/colors_agrosig.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../screens/settings/privacy_policy_screen.dart';

class PrivacyPolicyWidget extends StatefulWidget {
  final Function(bool) onAccepted;

  const PrivacyPolicyWidget({Key? key, required this.onAccepted}) : super(key: key);

  @override
  State<PrivacyPolicyWidget> createState() => _PrivacyPolicyWidgetState();
}

class _PrivacyPolicyWidgetState extends State<PrivacyPolicyWidget> {
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _checkPreviousAcceptance();
  }

  Future<void> _checkPreviousAcceptance() async {
    final accepted = await secureStorage.isPolicyAccepted();
    setState(() {
      _accepted = accepted;
    });
    widget.onAccepted(accepted);
  }

  void _toggleAccepted(bool? value) async {
    setState(() {
      _accepted = value ?? false;
    });
    await secureStorage.setPolicyAccepted(_accepted);
    widget.onAccepted(_accepted);
  }

  void _openPolicyScreen() {
    Get.to(() => const PrivacyPolicyScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _accepted,
          activeColor: ColorsAgrosig.primaryColor,
          onChanged: _toggleAccepted,
        ),
        Expanded(
          child: Wrap(
            children: [
              const Text(
                'Acepto la ',
                style: TextStyle(fontSize: 14),
              ),
              GestureDetector(
                onTap: _openPolicyScreen,
                child: const Text(
                  'Política de Privacidad',
                  style: TextStyle(
                    color: ColorsAgrosig.primaryColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(' y los '),
              GestureDetector(
                onTap: _openPolicyScreen,
                child: const Text(
                  'Términos de Uso',
                  style: TextStyle(
                    color: ColorsAgrosig.primaryColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text('.'),
            ],
          ),
        ),
      ],
    );
  }
}
