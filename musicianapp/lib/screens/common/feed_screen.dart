import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart.';
import 'package:musicianapp/common/common_widgets.dart';
import 'package:intl/intl.dart';
import 'package:musicianapp/common/globals.dart';
import 'package:musicianapp/screens/common/post_screen.dart';
import 'package:musicianapp/screens/explore/explore_screen.dart';
import 'package:musicianapp/screens/explore/videoplayer_screen.dart';
import 'package:video_player/video_player.dart';

//String str = 'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using Content here content here, making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for lorem ipsum will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.post_add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').where('connectedUIDs',arrayContains: Globals.userID).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinkit,);
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> postData = document.data()! as Map<String, dynamic>;

              Timestamp timestamp = postData['time'];
              DateTime dateTime = timestamp.toDate();
              String dateTimeStr = DateFormat('dd-MM-yyyy, kk:mm').format(dateTime);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    //height: 300,
                    color: Colors.indigo.shade50,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                child: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').doc(postData['authorUID']).get(),
                                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot>snapshot) {
                                    if (snapshot.hasError) {
                                      return Text("Something went wrong");
                                    }

                                    if (snapshot.hasData && !snapshot.data!.exists) {
                                      return Text("Document does not exist");
                                    }

                                    if (snapshot.connectionState == ConnectionState.done) {
                                      Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.green,
                                          backgroundImage: NetworkImage(userData['imageURL']),
                                        ),
                                        title: Text(
                                          userData['fName']+' '+userData['lName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(dateTimeStr),
                                      );
                                    }
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green,
                                      ),
                                      title: Text(''),
                                      subtitle: Text(dateTime.toString()),
                                    );
                                  },
                                ),
                                onTap: () {
                                  print('asd');
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.person_add_alt_1),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: Column(
                            children: [
                              Text(
                                postData['text'],
                                textAlign: TextAlign.justify,
                              ),
                              (postData['type']=='video')? VideoApp(postData['videoURL']) : SizedBox(),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: (Globals.likedPosts.contains(document.id))? TextButton(
                                onPressed: () {},
                                child: Icon(Icons.favorite,color: Colors.redAccent,),
                              ):TextButton(
                                onPressed: () {},
                                child: Icon(Icons.favorite_border,color: Colors.black87,),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PostScreen(document.id,postData['time'],postData['authorUID'],postData['fName'],5)),
                                  );
                                },
                                child: Icon(Icons.comment,color: Colors.black87,),
                              ),
                            ),
                          ],s
                        )
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
