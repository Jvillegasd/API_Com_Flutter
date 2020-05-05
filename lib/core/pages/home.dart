import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_api_consumer_login/core/providers/userProvider.dart';
import 'package:simple_api_consumer_login/core/pages/login.dart';
import 'package:simple_api_consumer_login/core/models/course.dart';
import 'package:simple_api_consumer_login/core/widgets/courseCard.dart';
import 'package:simple_api_consumer_login/core/widgets/dialogMessage.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Course> currentUserCourses = new List<Course>();
  bool _isLoading = true;
  bool _isLoadingRequest = false;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).authentication();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      if (userProvider.isLogged) {
        if (_isLoading) {
          _getCourses(userProvider);
          return Scaffold(
            appBar: AppBar(title: Text("Courses")),
            body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
              _getCourses(userProvider),
              Text("Loading courses")
            ])),
          );
        }
        double phoneHeight = MediaQuery.of(context).size.height;
        return Scaffold(
            appBar: AppBar(title: Text("Courses")),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: _list(),
                      height: phoneHeight * 0.70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: () async {
                          await userProvider.logOut();
                        },
                        tooltip: "Logout",
                        child: Icon(Icons.close),
                        backgroundColor: Colors.red,
                      ),
                      Container(child: _addButton(userProvider))
                    ],
                  )
                ]));
      } else
        return Login();
    });
  }

  Widget _list() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: currentUserCourses.length,
      itemBuilder: (context, index) {
        Course course = currentUserCourses[index];
        return CourseCard(course: course);
      },
    );
  }

  Widget _addButton(UserProvider userProvider) {
    return (_isLoadingRequest)
        ? _addCourse(userProvider)
        : FloatingActionButton(
            onPressed: () {
              setState(() {
                _isLoadingRequest = true;
              });
            },
            tooltip: "Create a new course",
            child: Icon(Icons.add),
            elevation: 15.0,
          );
  }

  Widget _addCourse(UserProvider userProvider) {
    userProvider.createCourse().then((response) {
      if (!response.containsKey("error")) {
        Course newCourse = Course(response["id"], response["name"],
            response["professor"], response["students"]);
        setState(() {
          _isLoadingRequest = false;
          currentUserCourses.add(newCourse);
        });
        return null;
      } else {
        setState(() {
          _isLoadingRequest = false;
        });
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return DialogMessage(
                  title: "Message", message: response["message"]);
            });
      }
    });
    return Center(child: CircularProgressIndicator());
  }

  Widget _getCourses(UserProvider userProvider) {
    userProvider.getCourses().then((response) {
      if (!response.containsKey("error")) {
        List<dynamic> courses = response["courses"];
        for (var element in courses) {
          Course course = Course(element["id"], element["name"],
              element["professor"], element["students"]);
          currentUserCourses.add(course);
        }
        setState(() {
          _isLoading = false;
        });
        return null;
      } else {
        setState(() {
          _isLoading = false;
        });
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return DialogMessage(
                  title: "Message", message: response["message"]);
            });
      }
    });
    return Center(child: CircularProgressIndicator());
  }
}
