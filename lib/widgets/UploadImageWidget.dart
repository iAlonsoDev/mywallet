import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

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
    return Center(
      child: Stack(
        children: [
          // Imagen o placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: isUploading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : uploadedImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: uploadedImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.account_balance,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.account_balance,
                        color: Colors.grey[400],
                        size: 40,
                      ),
          ),

          // Botón flotante de cámara
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isUploading ? null : pickAndUploadImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}