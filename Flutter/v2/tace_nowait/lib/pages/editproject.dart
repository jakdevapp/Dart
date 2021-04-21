import 'package:flutter/material.dart';

class EditProject extends StatefulWidget {
  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  TextEditingController controllerProjectTitle = TextEditingController();
  TextEditingController controllerProjectContent = TextEditingController();
  bool isFieldProjectTitleValid;
  bool isFieldProjectContentValid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _buildProjectTitle(),
            SizedBox(height: 10),
            _buildProjectContent()
          ],
        ),
      ),
    );
  }

  Widget _buildProjectTitle() {
    return TextField(
      controller: controllerProjectTitle,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Project Title",
        errorText: isFieldProjectTitleValid == null || isFieldProjectTitleValid
            ? null
            : "Project Title is required",
      ),
      onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != isFieldProjectTitleValid) {
          setState(() => isFieldProjectTitleValid = isFieldValid);
        }
      },
    );
  }

  Widget _buildProjectContent() {
    return TextField(
      controller: controllerProjectContent,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Project Content",
        errorText: isFieldProjectContentValid == null || isFieldProjectContentValid
            ? null
            : "Project Content is required",
      ),
      onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != isFieldProjectContentValid) {
          setState(() => isFieldProjectContentValid = isFieldValid);
        }
      },
    );
  }
}
