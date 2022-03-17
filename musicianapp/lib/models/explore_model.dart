import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:provider/provider.dart';

class Explorer with ChangeNotifier{

  List<String> filterSettings = [];
  final geo = Geoflutterfire();
  List<String> videoList = [];

 void searchUsersByMusic(String role, String instrument, List<String> genres) {
   print('ZZZZZZZZZZZZZZZZZMMMMMMMMMMMMMMMMMAAAAAAAAAAAAAAAA');
    videoList.clear();
    FirebaseFirestore.instance.collection('users')
        .where('role', isEqualTo: role)
        .where('instrument', isEqualTo: instrument)
        .where('genres', arrayContainsAny: genres)
        .get()
        .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            videoList.add(doc['videoLink']);
            print(doc["name"]);
          }
          notifyListeners();
        }
      );
  }

  void searchUsersByDistance(double radius){
    GeoFirePoint center = geo.point(latitude: 7.242016, longitude: 80.857134);
    String field = 'location';
    var collectionReference = FirebaseFirestore.instance.collection('users');
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference).within(center: center, radius: radius, field: field);
    stream.listen((List<DocumentSnapshot> documentList) {
      for (var document in documentList) {
        print(document['videoLink']);
        videoList.add(document['videoLink']);
      }
      notifyListeners();
    });
  }

  void writeGeoData() {
    GeoFirePoint myLocation = geo.point(latitude: 7.206750, longitude: 80.848153);
    GeoFirePoint myLocation1 = geo.point(latitude: 7.195850, longitude: 80.677751);
    GeoFirePoint myLocation2 = geo.point(latitude: 7.201300, longitude: 80.523840);
    GeoFirePoint myLocation3 = geo.point(latitude: 6.955992, longitude: 80.276482);
    GeoFirePoint myLocation4 = geo.point(latitude: 6.235698, longitude: 80.303966);
    FirebaseFirestore.instance.collection('users').doc('anneblake@gmail.com').update({'location': myLocation.data});
    FirebaseFirestore.instance.collection('users').doc('emmamclean@gmail.com').update({'location': myLocation1.data});
    FirebaseFirestore.instance.collection('users').doc('hasirunmp@gmail.com').update({'location': myLocation2.data});
    FirebaseFirestore.instance.collection('users').doc('oliverbrown@gmail.com').update({'location': myLocation3.data});
    FirebaseFirestore.instance.collection('users').doc('yosJBYpOiVgqDWUZGDaV5pbxs3p2').update({'location': myLocation4.data});
  }
}




