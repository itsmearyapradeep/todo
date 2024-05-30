import 'package:hive/hive.dart';
import '../model/users.dart';


class HiveDB{

  HiveDB._internal();

  static HiveDB instance = HiveDB._internal();

  //factory constructor
  factory HiveDB(){
    return instance;
  }

  Future<List<Users>>  getUsers() async{
    final db = await Hive.openBox<Users>('users');
    return db.values.toList();
  }

  Future<void> addUser(Users user) async{
    final db = await Hive.openBox<Users>('users');
    db.put(user.id, user);
  }
}