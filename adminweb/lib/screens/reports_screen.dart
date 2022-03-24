import 'package:adminweb/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {

  String _selectedDoc = 'none';
  String _selectedDocUID = 'none';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return InkWell(
                    onTap: (){
                      setState(() {
                        _selectedDoc = document.id;
                        _selectedDocUID = data['reporteeUID'];
                      });
                    },
                    child: Card(
                      elevation: 0,
                      child: ListTile(
                        title: Text(data['reporterName']),
                        subtitle: Text(
                          data['content'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        VerticalDivider(),
        Expanded(
          flex: 5,
          child: _selectedDoc != 'none'? reportDetails(_selectedDoc) : Center(child: Text('Select A Report'),),
        ),
        VerticalDivider(),
        Expanded(
          flex: 5,
          child: _selectedDoc != 'none'? ProfileScreen(_selectedDocUID) : Center(child: Text('Select A Report'),),
        ),
      ],
    );
  }
  Widget reportDetails(String docID){
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('reports').doc(docID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return ListView(
            children: [
              ListTile(
                title: Text('REPORTER'),
                subtitle: Text(data['reporterName']),
                textColor: Colors.black,
              ),
              ListTile(
                title: Text('REPORTEE'),
                subtitle: Text(data['reporteeName']),
                textColor: Colors.black,
              ),
              ListTile(
                title: Text('DATE'),
                subtitle: Text(data['time'].toString()),
                textColor: Colors.black,
              ),
              ListTile(
                title: Text('CONTENT'),
                subtitle: Text(data['content']),
                textColor: Colors.black,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: (){},
                        child: Text('Mark As Action Taken'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: (){},
                        child: Text('Ignore'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return Text("loading");
      },
    );
  }
}
