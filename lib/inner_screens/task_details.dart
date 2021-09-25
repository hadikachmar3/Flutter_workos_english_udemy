import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workos_english/constants/constants.dart';
import 'package:workos_english/services/global_methods.dart';
import 'package:workos_english/widgets/comments_widget.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({required this.uploadedBy, required this.taskID});
  final String uploadedBy;
  final String taskID;

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  var _textstyle = TextStyle(
      color: Constants.darkBlue, fontSize: 13, fontWeight: FontWeight.normal);
  var _titlesStyle = TextStyle(
      color: Constants.darkBlue, fontWeight: FontWeight.bold, fontSize: 20);
  TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  String? authorName;
  String? authorPosition;
  String? userImageUrl;
  String? _loggedInUserImageUrl;
  String? taskCategory;
  String? taskDescription;
  String? tasktitle;
  bool? _isDone;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  bool isDeadlineAvailable = false;
  //Added new
  String? _loggedUserName;
  @override
  void initState() {
    super.initState();
    getTaskData();
  }

  void getTaskData() async {
    //New to fix the bug
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    final DocumentSnapshot getCommenterInfoDoc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (getCommenterInfoDoc == null) {
      return;
    } else {
      setState(() {
        _loggedUserName = getCommenterInfoDoc.get('name');
        _loggedInUserImageUrl = getCommenterInfoDoc.get('userImage');
      });
    }
    //
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();
    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        authorPosition = userDoc.get('positionInCompany');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot taskDatabase = await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskID)
        .get();
    if (taskDatabase == null) {
      return;
    } else {
      setState(() {
        tasktitle = taskDatabase.get('taskTitle');
        taskDescription = taskDatabase.get('taskDescription');
        _isDone = taskDatabase.get('isDone');
        postedDateTimeStamp = taskDatabase.get('createdAt');
        deadlineDateTimeStamp = taskDatabase.get('deadlineDateTimeStamp');
        deadlineDate = taskDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });

      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Back',
            style: TextStyle(
                color: Constants.darkBlue,
                fontStyle: FontStyle.italic,
                fontSize: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Text(
              tasktitle == null ? '' : tasktitle!,
              style: TextStyle(
                  color: Constants.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Uploaded by ',
                              style: TextStyle(
                                  color: Constants.darkBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          Spacer(),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: Colors.pink.shade700,
                              ),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(userImageUrl == null
                                      ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                                      : userImageUrl!),
                                  fit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName == null ? '' : authorName!,
                                style: _textstyle,
                              ),
                              Text(
                                authorPosition == null ? '' : authorPosition!,
                                style: _textstyle,
                              ),
                            ],
                          )
                        ],
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploaded on:',
                            style: _titlesStyle,
                          ),
                          Text(
                            postedDate == null ? '' : postedDate!,
                            style: TextStyle(
                                color: Constants.darkBlue,
                                fontWeight: FontWeight.normal,
                                fontSize: 15),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deadline date:',
                            style: _titlesStyle,
                          ),
                          Text(
                            deadlineDate == null ? '' : deadlineDate!,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.normal,
                                fontSize: 15),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          isDeadlineAvailable
                              ? 'Deadline is not finished yet'
                              : ' Deadline passed',
                          style: TextStyle(
                              color: isDeadlineAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.normal,
                              fontSize: 15),
                        ),
                      ),
                      dividerWidget(),
                      Text(
                        'Done state:',
                        style: _titlesStyle,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              User? user = _auth.currentUser;
                              final _uid = user!.uid;
                              if (_uid == widget.uploadedBy) {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(widget.taskID)
                                      .update({'isDone': true});
                                } catch (err) {
                                  GlobalMethod.showErrorDialog(
                                      error: 'Action cant be performed',
                                      ctx: context);
                                }
                              } else {
                                GlobalMethod.showErrorDialog(
                                    error: 'You cant perform this action',
                                    ctx: context);
                              }

                              getTaskData();
                            },
                            child: Text(
                              'Done',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  color: Constants.darkBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Opacity(
                            opacity: _isDone == true ? 1 : 0,
                            child: Icon(
                              Icons.check_box,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          TextButton(
                            onPressed: () {
                              User? user = _auth.currentUser;
                              final _uid = user!.uid;
                              if (_uid == widget.uploadedBy) {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(widget.taskID)
                                      .update({'isDone': false});
                                } catch (err) {
                                  GlobalMethod.showErrorDialog(
                                      error: 'Action cant be performed',
                                      ctx: context);
                                }
                              } else {
                                GlobalMethod.showErrorDialog(
                                    error: 'You cant perform this action',
                                    ctx: context);
                              }

                              getTaskData();
                            },
                            child: Text(
                              'Not Done',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  color: Constants.darkBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Opacity(
                            opacity: _isDone == false ? 1 : 0,
                            child: Icon(
                              Icons.check_box,
                              color: Colors.red,
                            ),
                          )
                        ],
                      ),
                      dividerWidget(),
                      Text(
                        'Task Description',
                        style: _titlesStyle,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        taskDescription == null ? '' : taskDescription!,
                        style: _textstyle,
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: 500,
                        ),
                        child: _isCommenting
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style:
                                          TextStyle(color: Constants.darkBlue),
                                      maxLength: 200,
                                      keyboardType: TextInputType.text,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.pink),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                      child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: MaterialButton(
                                          onPressed: () async {
                                            if (_commentController.text.length <
                                                7) {
                                              GlobalMethod.showErrorDialog(
                                                  error:
                                                      'Comment cant be less than 7 characteres',
                                                  ctx: context);
                                            } else {
                                              User? user = _auth.currentUser;
                                              final _uid = user!.uid;
                                              // print('Uid is $_uid');
                                              // print(
                                              //     'uploaded by id is ${widget.uploadedBy}');

                                              final _generatedId = Uuid().v4();
                                              await FirebaseFirestore.instance
                                                  .collection('tasks')
                                                  .doc(widget.taskID)
                                                  .update({
                                                'taskComments':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    //There was a bug here we should upload the current logged in user
                                                    //instead of the uploader ID
                                                    'userId': _uid,
                                                    'commentId': _generatedId,
                                                    //and for the name it was the author name
                                                    //it should be the current logged in username
                                                    'name': _loggedUserName,
                                                    //Also we need to change the image
                                                    'userImageUrl':
                                                        _loggedInUserImageUrl,
                                                    'commentBody':
                                                        _commentController.text,
                                                    'time': Timestamp.now(),
                                                  }
                                                ]),
                                              });
                                              await Fluttertoast.showToast(
                                                  msg:
                                                      "Your comment has been added",
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  // gravity: ToastGravity.,
                                                  backgroundColor: Colors.grey,
                                                  fontSize: 18.0);
                                              _commentController.clear();
                                            }
                                            setState(() {});
                                          },
                                          color: Colors.pink.shade700,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Text(
                                            'Post',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isCommenting = !_isCommenting;
                                            });
                                          },
                                          child: Text('Cancel'))
                                    ],
                                  ))
                                ],
                              )
                            : Center(
                                child: MaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      _isCommenting = !_isCommenting;
                                    });
                                  },
                                  color: Colors.pink.shade700,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Text(
                                      'Addd a Comment',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(widget.taskID)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              if (snapshot.data == null) {
                                Center(child: Text('No Comment for this task'));
                              }
                            }
                            return ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return CommentWidget(
                                    commentId: snapshot.data!['taskComments']
                                        [index]['commentId'],
                                    commenterId: snapshot.data!['taskComments']
                                        [index]['userId'],
                                    commentBody: snapshot.data!['taskComments']
                                        [index]['commentBody'],
                                    commenterImageUrl:
                                        snapshot.data!['taskComments'][index]
                                            ['userImageUrl'],
                                    commenterName: snapshot
                                        .data!['taskComments'][index]['name'],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    thickness: 1,
                                  );
                                },
                                itemCount:
                                    snapshot.data!['taskComments'].length);
                          })
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dividerWidget() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
