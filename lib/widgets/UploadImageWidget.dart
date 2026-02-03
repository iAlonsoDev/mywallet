import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UploadImageWidget extends StatefulWidget {
  final void Function(String imageUrl) onUploaded;
  final String? initialImageUrl;

  const UploadImageWidget({super.key, required this.onUploaded, this.initialImageUrl});

  @override
  State<UploadImageWidget> createState() => _UploadImageWidgetState();
}

class _UploadImageWidgetState extends State<UploadImageWidget> {
  String? uploadedImageUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    uploadedImageUrl = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(covariant UploadImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImageUrl != widget.initialImageUrl) {
      uploadedImageUrl = widget.initialImageUrl;
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se seleccionó ninguna imagen')),
        );
      }
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final uploadUrl =
          Uri.parse('https://api.cloudinary.com/v1_1/decwc31n0/image/upload');
      final request = http.MultipartRequest('POST', uploadUrl)
        ..fields['upload_preset'] = 'mywallet_pictures';

      if (kIsWeb) {
        // En la web, usamos los bytes de la imagen
        final bytes = await pickedFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'image.jpg',
        ));
      } else {
        // En móviles, usamos el archivo
        final file = await pickedFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file,
          filename: 'image.jpg',
        ));
      }

      final response = await request.send();
      print('Código de estado: ${response.statusCode}'); // Para depuración

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resData = jsonDecode(resStr);
        setState(() {
          uploadedImageUrl = resData['secure_url'];
          isUploading = false;
        });
        widget.onUploaded(uploadedImageUrl!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida correctamente')),
          );
        }
      } else {
        throw Exception('Error al subir la imagen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en pickAndUploadImage: $e'); // Para depuración
      setState(() {
        isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUploading)
            const Center(child: CircularProgressIndicator())
          else if (uploadedImageUrl != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    uploadedImageUrl!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Imagen subida',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            )
          else
            const Text(
              'No se ha seleccionado ninguna imagen',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: isUploading ? null : pickAndUploadImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(uploadedImageUrl != null ? 'Cambiar Imagen' : 'Seleccionar Imagen'),
          ),
        ],
      ),
    );
  }
}