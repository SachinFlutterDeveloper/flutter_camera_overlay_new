import 'package:digihealthcardapp/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User_view_model with ChangeNotifier {
  Future<bool> saveUser(user user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('id', user.id.toString());
    // print('saved id: ${user.id.toString()}');
    sp.setString('email', user.email.toString());
    // print('saved id: ${user.email.toString()}');
    sp.setString('username', user.username.toString());
    // print('saved id: ${user.username.toString()}');
    sp.setString('phone', user.phone.toString());
    // print('saved id: ${user.phone.toString()}');
    sp.setString('gender', user.gender.toString());
    sp.setString('email', user.email.toString());
    // print('saved id: ${user.email.toString()}');
    sp.setString('first_name', user.firstName.toString());
    // print('saved id: ${user.firstName.toString()}');
    sp.setString('last_name', user.lastName.toString());
    // print('saved id: ${user.lastName.toString()}');
    sp.setString('image', user.image.toString());
    // print('saved id: ${user.image.toString()}');
    sp.setString('occupation', user.occupation.toString());
    sp.setString('marital_status', user.maritalStatus.toString());
    sp.setString('birthdate', user.birthdate.toString());
    sp.setString('gender', user.gender.toString());
    sp.setString('device_token', user.deviceToken.toString());
    sp.setString('residency', user.residency.toString());
    sp.setString('city', user.city.toString());
    sp.setString('state', user.state.toString());
    sp.setString('country', user.country.toString());
    sp.setString('zipcode', user.zipcode.toString());
    sp.setString('relationship', user.relationship.toString());
    // print('saved relation: ${user.relationship.toString()}');
    sp.setString('insurance', user.insurance.toString());
    sp.setString('is_approved', user.isApproved.toString());
    notifyListeners();
    return true;
  }

  Future<user> getUser() async {
    WidgetsFlutterBinding.ensureInitialized();
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? id = sp.getString('id');
    final String? email = sp.getString('email');
    final String? firstName = sp.getString('first_name');
    final String? lastName = sp.getString('last_name');
    final String? phone = sp.getString('phone');
    final String? username = sp.getString('username');
    final String? image = sp.getString('image');
    final String? isApproved = sp.getString('is_approved');
    // print('retrieved id: $id');
    return user(
      id: id.toString(),
      email: email.toString(),
      firstName: firstName.toString(),
      lastName: lastName.toString(),
      phone: phone.toString(),
      username: username.toString(),
      image: image.toString(),
      isApproved: isApproved.toString(),
    );
  }

  Future<user> getName() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? firstName = sp.getString('first_name');
    final String? lastName = sp.getString('last_name');
    return user(
      firstName: firstName.toString(),
      lastName: lastName.toString(),
    );
  }

  Future<bool> remove() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
    sp.remove('id');
    sp.remove('first_name');
    sp.remove('last_name');
    sp.remove('email');
    sp.remove('image');
    sp.remove('phone');
    sp.remove('image');
    sp.remove('occupation');
    sp.remove('marital_status');
    sp.remove('birthdate');
    sp.remove('username');
    sp.remove('gender');
    sp.remove('device_token');
    sp.remove('residency');
    sp.remove('city');
    sp.remove('state');
    sp.remove('country');
    sp.remove('zipcode');
    sp.remove('relationship');
    sp.remove('insurance');
    sp.remove('is_approved');
    return true;
  }
}
