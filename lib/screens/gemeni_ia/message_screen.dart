import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../components/animations/animation_route.dart';
import '../../components/theme/colors_agroSig.dart';
import '../../components/theme/theme_notifier.dart';
import '../../domain/models/message/message_model.dart';
import 'ia_onbording_screen.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Función mejorada para llamar al modelo
  Future<void> callGeminiModel() async {
    if (_controller.text.isEmpty || _isSending) return;

    setState(() {
      _isLoading = true;
      _isSending = true;
      _messages.add(Message(text: _controller.text, isUser: true));
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: dotenv.env['GOOGLE_API_KEY']!,
        generationConfig: GenerationConfig(
          temperature: 0.7,       // Controla la creatividad (0=más preciso, 1=más creativo)
          topK: 40,               // Mejor para respuestas en español
          topP: 0.95,             // Mejor para coherencia
          //maxOutputTokens: 1024,  // Límite de longitud de respuesta
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        ],
      );

      final prompt = _controller.text.trim();
      List<Content> content = [Content.text(prompt)];

      // Si hay imagen seleccionada, agregarla al contenido
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ];
      }

      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(text: response.text ?? "No response", isUser: false));
        _isLoading = false;
        _isSending = false;
        _selectedImage = null;
      });

      _controller.clear();
    } catch (error) {
      print("Error: $error");
      setState(() {
        _messages.add(Message(text: "Error: $error", isUser: false));
        _isLoading = false;
        _isSending = false;
      });
    }
  }

  // Función para seleccionar imagen
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Función para eliminar imagen seleccionada
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : ColorsAgrosig.primaryColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.push(context, routeAgroSig(page: IAOnbording()));
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            Row(
              children: [
                Image.asset(
                  'assets/images/gpt-robot.png',
                  color: isDarkMode ? Colors.white : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'Gemini IA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onTap: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Indicador de encriptación
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'chat end-to-end encrypted',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingIndicator();
                }
                final message = _messages[index];
                return _buildMessageBubble(message, context);
              },
            ),
          ),

          // Imagen seleccionada preview
          if (_selectedImage != null)
            _buildImagePreview(),

          // Input de usuario
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Gemini está pensando...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: message.isUser
                      ? Colors.transparent
                      : Theme.of(context).dividerColor.withOpacity(0.3),
                ),
                boxShadow: [
                  if (!message.isUser)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: message.isUser
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Imagen seleccionada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            onPressed: _removeImage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón para seleccionar imagen
          IconButton(
            icon: Icon(
              Icons.photo_library_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            onPressed: _pickImage,
          ),
          const SizedBox(width: 4),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: _controller,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => callGeminiModel(),
            ),
          ),

          const SizedBox(width: 8),

          // Botón de enviar
          _isLoading
              ? Container(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
              : IconButton(
            icon: Icon(
              Icons.send,
              color: _controller.text.isEmpty
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            onPressed: _isSending ? null : callGeminiModel,
          ),
        ],
      ),
    );
  }
}