import 'package:chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });

    if (_currentUser != null) {
      print('entrou no schedule');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));
      });
    }
  }

  Future _getUser() async {
    if (_currentUser != null) {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => ChatScreen()));
      _currentUser = null;
      FirebaseAuth.instance.signOut();
      googleSignIn.signOut();
    }

    try
    {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      AuthResult authresult = await _auth.signInWithCredential(credential);
      _currentUser = authresult.user;

      if (_currentUser != null) {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));
        _currentUser = null;
        FirebaseAuth.instance.signOut();
        googleSignIn.signOut();
      }
    }
    catch(error){
      print('erro: ' + error.toString());
	  _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível efetuar o login na sua conta Google, tente novamente. Erro: ${error.toString()}"),
          backgroundColor: Colors.red,
        )
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
	  key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Seja bem vindo!", style: TextStyle(fontSize: 15),),
              IconButton(
                icon: Icon(Icons.chat), iconSize: 120,
                onPressed: () async { await _getUser(); },
              ),
              Text("Clique acima e entre com sua conta Google", style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      )
    );
  }
}
