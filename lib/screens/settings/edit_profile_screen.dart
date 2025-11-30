import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../components/custom/text_custom.dart';
import '../../components/forms/form_fiel.dart';
import '../../components/helper/error_message.dart';
import '../../components/helper/validate_form.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../components/helper/modal_success.dart';
import '../../data/local_secure/secure_storage.dart';
import '../../domain/services/user_services/user_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _keyForm = GlobalKey<FormState>();
  final UserServices _userServices = UserServices();
  final SecureStorageAgroSig _secureStorage = SecureStorageAgroSig();

  // Controladores para los campos de texto
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _paternalSurnameController = TextEditingController();
  final TextEditingController _maternalSurnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userServices.getUserProfile();
      setState(() {
        _firstNameController.text = user.first_name;
        _paternalSurnameController.text = user.paternal_surname;
        _maternalSurnameController.text = user.maternal_surname;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      errorMessageSnack(context, 'Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_keyForm.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        final updatedUser = await _userServices.updateUserProfile(
          first_name: _firstNameController.text.trim(),
          paternal_surname: _paternalSurnameController.text.trim(),
          maternal_surname: _maternalSurnameController.text.trim(),
          email: _emailController.text.trim(),
        );

        // Mostrar modal de éxito
        modalSuccess(
          context,
          'Perfil actualizado correctamente',
              () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
        );
      } catch (e) {
        // Mostrar modal de error
        errorMessageSnack(context, 'Error al actualizar perfil: $e');
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 10.0),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorsAgrosig.primaryColor,
                size: 17,
              ),
              TextCustom(
                text: 'Volver',
                fontSize: 17,
                color: ColorsAgrosig.primaryColor,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _updateProfile,
            child: _isUpdating
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
                : TextCustom(
              text: "Actualizar Perfil",
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Form(
          key: _keyForm,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: [
              const TextCustom(
                text: 'Nombre',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _firstNameController,
                validator: RequiredValidator(errorText: 'El nombre es requerido'),
              ),
              const SizedBox(height: 20.0),

              const TextCustom(
                text: 'Apellido Paterno',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _paternalSurnameController,
                hintText: 'Apellido Paterno',
                validator: RequiredValidator(errorText: 'El apellido paterno es requerido'),
              ),
              const SizedBox(height: 20.0),

              const TextCustom(
                text: 'Apellido Materno',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _maternalSurnameController,
                hintText: 'Apellido Materno',
                validator: RequiredValidator(errorText: 'El apellido materno es requerido'),
              ),
              const SizedBox(height: 20.0),

              const TextCustom(
                text: 'Email Address',
                color: ColorsAgrosig.secundaryColor,
              ),
              const SizedBox(height: 5.0),
              FormFieldAgro(
                controller: _emailController,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'El email es requerido'),
                  EmailValidator(errorText: 'Ingrese un email válido'),
                ]),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalSurnameController.dispose();
    _maternalSurnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}