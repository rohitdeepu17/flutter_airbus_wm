import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

class FileUploadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('UPLOAD FILE'),
      onPressed: () async {
        var picked = await FilePicker.platform.pickFiles();

        if (picked != null) {
          print(picked.files.first.name);
        }
      },
    );
  }
}