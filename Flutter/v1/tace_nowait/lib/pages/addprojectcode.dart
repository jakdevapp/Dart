import 'package:flutter/material.dart';
import 'package:tace_nowait/database/project_dbhelper.dart';
import 'package:tace_nowait/model/project.dart';

class AddProjectCode extends StatefulWidget {
  @override
  _AddProjectCodeState createState() => _AddProjectCodeState();
}

class _AddProjectCodeState extends State<AddProjectCode> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controllerProjectCode = TextEditingController();

  Project project = Project();
  List<Project> projectList = List<Project>();
  ProjectDBHelper dbHelper;
  var projects;

  @override
  void initState() {
    super.initState();
    dbHelper = ProjectDBHelper();
    _refreshContactList();
  }

  _refreshContactList() async {
    List<Project> lists = await dbHelper.readProjects();
    setState(() {
      projectList = lists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text('Add Project Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  _form() => Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Add Project Code',
                ),
                keyboardType: TextInputType.text,
                validator: (val) =>
                    (val.length == 0 ? 'Project code is required' : null),
                onSaved: (val) => setState(() => project.projectid = val),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: RaisedButton(
                  onPressed: () {
                    _onSubmit();
                  },
                  child: Text('Add'),
                ),
              ),
            ],
          ),
        ),
      );

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        projectList[index].projectid.toUpperCase(),
                      ),
                      onTap: () {},
                      trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            await dbHelper.deleteProject(projectList[index].id);
                            _resetForm();
                            _refreshContactList();
                          }),
                    ),
                    Divider(
                      height: 5.0,
                    ),
                  ],
                );
              },
              itemCount: projectList.length,
            ),
          ),
        ),
      );

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      project = Project(projectid: project.projectid);
      await dbHelper.createProject(project);
      form.reset();
      await _refreshContactList();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState.reset();
      controllerProjectCode.clear();
      project.id = null;
    });
  }
}