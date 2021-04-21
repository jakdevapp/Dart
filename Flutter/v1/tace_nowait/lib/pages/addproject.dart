import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProject extends StatefulWidget {
  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  String projectName;
  TextEditingController controllerProjectTitle = TextEditingController();
  TextEditingController controllerProjectContent = TextEditingController();
  bool isFieldProjectTitleValid;
  bool isFieldProjectContentValid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _buildProjectTitle(),
            SizedBox(height: 10),
            Text('Project name : $projectName'),
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

  Future _getSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      projectName = preferences.get("project") ?? "Please fill project name";
    });
  }

  Future _saveSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString("project", controllerProjectTitle.text);
  }
}


