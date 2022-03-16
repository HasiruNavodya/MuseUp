import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicianapp/models/explore_model.dart';
import 'package:musicianapp/screens/explore/profile_screen.dart';
import 'package:musicianapp/screens/account/setprofile_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

List<String> videoList=[];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({ Key? key }) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

  @override
  Widget build(BuildContext context) {

    final PageController controller = PageController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(onPressed: (){showFilterView();}, icon: const Icon(CupertinoIcons.bars),)
        ],
      ),
      body: SafeArea(
        child: Consumer<Explorer>(
          builder: (context, explorerModel, child) {
            return PageView(
              controller: controller,
              scrollDirection: Axis.vertical,
              allowImplicitScrolling: true,
              children: List<Widget>.generate(explorerModel.videoList.length, (int index) {
                return VideoApp(explorerModel.videoList[index]);
              },
              ).toList(),
            );
          },
        ),
      ),
    );
  }
  void showFilterView(){
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return FilterView();
      },
    );
  }

  void updateSearch(){
    setState(() {});
  }
}

enum filterType {byDistance, byRole}

class FilterView extends StatefulWidget {
  const FilterView({Key? key}) : super(key: key);

  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {

  filterType _type = filterType.byRole;
  List roleList = ['Any Role','Composer','Instrumentalist','Vocalist', 'Producer'];
  List genreList = ['Any Genre','Pop','Classical','Rock', 'Jazz'];
  List instrumentList = ['Any Instrument','Guitar','Piano','Drums', 'Violin','Harp','Cello','Trumpet','Viola','Bass Guitar','Percussion','Flute'];
  String? roleChoice;
  String? genreChoice;
  String? instrumentChoice;
  double distance = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Filter Settings'),
            IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.close),),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Radio<filterType>(
                  value: filterType.byRole,
                  groupValue: _type,
                  onChanged: (filterType? value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                Text('By Role'),
              ],
            ),
            Row(
              children: [
                Radio<filterType>(
                  value: filterType.byDistance,
                  groupValue: _type,
                  onChanged: (filterType? value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                ),
                Text('By Distance'),
              ],
            ),
          ],
        ),
        Expanded(
          child: _type == filterType.byRole ? filterContentRole() : filterContentDistance(),
        ),

      ],
    );
  }
  Widget filterContentRole(){
    return ListView(
      children: [
        Text('ROLE'),
        Wrap(
          children: List<Widget>.generate(roleList.length, (int index) {
            return ChoiceChip(
              label: Text(roleList[index]),
              selected: roleChoice == roleList[index],
              onSelected: (bool selected) {
                setState(() {
                  roleChoice = selected ? roleList[index] : null;
                });
              },
            );
          },
          ).toList(),
        ),
        Text('GENRE'),
        Wrap(
          children: List<Widget>.generate(genreList.length, (int index) {
            return ChoiceChip(
              label: Text(genreList[index]),
              selected: genreChoice == genreList[index],
              onSelected: (bool selected) {
                setState(() {
                  genreChoice = selected ? genreList[index] : null;
                });
              },
            );
          },
          ).toList(),
        ),
        Text('INSTRUMENT'),
        Container(
          child: roleChoice != 'Instrumentalist' ? Center(child: Text('Not Applicable'),) :
          Wrap(
            children: List<Widget>.generate(instrumentList.length, (int index) {
              return ChoiceChip(
                label: Text(instrumentList[index]),
                selected: instrumentChoice == instrumentList[index],
                onSelected: (bool selected) {
                  setState(() {
                    instrumentChoice = selected ? instrumentList[index] : null;
                  });
                },
              );
            },
            ).toList(),
          ),
        ),
        Center(
          child: Consumer<Explorer>(
            builder: (context, explorerModel, child) {
              return ElevatedButton(
                onPressed: (){
                  explorerModel.searchUsersByMusic();
                  Navigator.pop(context);
                  //videoList = explorerModel.videoList;
                },
                child: const Text('SEARCH'),
              );
            }
          ),
        ),

      ],
    );
  }

  Widget filterContentDistance(){
    return ListView(
      children: [
        SizedBox(height: 60,),
        Center(child: Text('${distance.round().toString()} km'),),
        Slider(
          value: distance,
          min: 1,
          max: 100,
          //divisions: 10,
          label: distance.round().toString(),
          onChanged: (double value) {
            setState(() {
              distance = value;
            });
          },
        ),
        SizedBox(height: 20,),
        Center(
          child: ElevatedButton(onPressed: (){}, child: Text('SEARCH'),),
        ),
      ],
    );
  }
}



class VideoApp extends StatefulWidget {
  String link;
  VideoApp(this.link, {Key? key}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.link)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    //_controller.play();
    return Stack(
      children: [
        SizedBox(
          //width: MediaQuery.of(context).size.width,
          child: _controller.value.isInitialized ? VideoPlayer(_controller) : const Center(child: Text('Loading'),),
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _controller.value.isPlaying ? (){
                      setState(() {
                        _controller.pause();
                      });
                    } : (){
                      setState(() {
                        _controller.play();
                      });
                    },
                    child: _controller.value.isPlaying ? Icon(Icons.pause,color: Colors.white,) : Icon(Icons.play_arrow,color: Colors.white,),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      primary: Color(0xFF303952), // <-- Button color
                      onPrimary: Color(0xFF40407a), // <-- Splash color
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showProfileView();
                    },
                    child: Icon(Icons.person,color: Colors.white,),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      primary: Color(0xFF303952), // <-- Button color
                      onPrimary: Color(0xFF40407a), // <-- Splash color
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  void play(){

  }

  void showProfileView(){
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return ProfileScreen('');
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


}

class CircleButton extends StatelessWidget {

  Function function;
  Icon icon;

  CircleButton({
    required this.function,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        function;
      },
      child: icon,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        primary: Colors.blue, // <-- Button color
        onPrimary: Colors.red, // <-- Splash color
      ),
    );
  }
}