
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../database/hive_db.dart';
import '../model/users.dart';

class Hive_Reg extends StatelessWidget {
  final name_controller =TextEditingController();
  final email_controller =TextEditingController();
  final pwd_controller =TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration Page"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Registration Page"),
              const SizedBox(height: 15,),

              TextField(
                controller: name_controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Name"
                ) ,
              ),
              TextField(
                controller: email_controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email"
                ) ,
              ),
              TextField(
                controller: pwd_controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password"
                ) ,
              ),
              MaterialButton(onPressed: () async {
                final userList = await HiveDB.instance.getUsers();
                validateSignup(userList);
                name_controller.clear();
                email_controller.clear();
                pwd_controller.clear();
              },
                shape: const StadiumBorder(),
                color: Colors.pink,
                child: const Text("Register Here"),)
            ],
          ),
        ),
      ),
    );
  }

  void validateSignup(List<Users> userList) async{
    final name= name_controller.text;
    final email =email_controller.text;
    final pswrd =pwd_controller.text;

    bool userExist = false;

    final validateEmail =EmailValidator.validate(email);
    if (name !=""&& email != "" && pswrd != "") {
      if (validateEmail == true ) {
        await Future.forEach(userList, (user) {
          if (user.email == email){
            userExist =true;

          } else {
            userExist = false;

          }
        });
        if ( userExist == true) {
          Get.snackbar("Error!", "User Already Exist!!!");

        } else {
          final validatePassword = checkPassword(pswrd);
          if ( validatePassword == true) {
            final user = Users(email: email,password: pswrd,name: name);
            await HiveDB.instance.addUser(user);
            Get.back();
            Get.snackbar("Success", "User Registration Successfull");
          }
        }
      }else{
        Get.snackbar("Error", "Enter a valid email !!!");
      }
    }else {
      Get.snackbar("Error", "Please fill all the fields");
    }
  }
  checkPassword(String pswrd) {
    if (pswrd.length < 6) {
      Get.snackbar("Error", "Password length must be > 6");
      return false;
    }else {
      return true ;
    }
  }
}