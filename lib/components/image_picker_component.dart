import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerComponent extends StatefulWidget {
  final Function(File?) onImageSelected;

  ImagePickerComponent({required this.onImageSelected});

  @override
  _ImagePickerComponentState createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final selectedSource = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () => Navigator.of(context).pop(0),
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Pick from Gallery'),
                onTap: () => Navigator.of(context).pop(1),
              ),
            ],
          ),
        );
      },
    );

    if (selectedSource != null) {
      final pickedFile = selectedSource == 0
          ? await picker.pickImage(source: ImageSource.camera)
          : await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        widget.onImageSelected(_image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_image != null)
          Image.file(
            _image!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text(_image == null ? 'Select Image' : 'Image Selected'),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}
