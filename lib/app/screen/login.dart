import 'package:chat_app/app/screen/chatground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chat_app/app/screen/register.dart';
import 'package:chat_app/app/screen/chatlist.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  Future init() async {
    prefs = await SharedPreferences.getInstance();
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatList(prefs.getString('nickname'))));
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('입장'),
        ),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              // Container(
              //     margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              //     child:
              //         TextButton(child: Text('구글 아이디로 로그인'), onPressed: login)),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: TextButton(
                    child: Text('회원가입'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterUser()));
                    },
                  )),
            ])))));
  }

  Future login() async {
    try {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });

        // Write data to local
        await prefs.setString('id', firebaseUser.uid);
        await prefs.setString('nickname', firebaseUser.displayName);
        await prefs.setString('photoUrl', firebaseUser.photoUrl);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatList(firebaseUser.displayName)));
    } catch (e) {
      showToast('자동 로그인 할 수 없습니다');
    }
  }
}
