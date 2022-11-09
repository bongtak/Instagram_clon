import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false, //디버그 모드 해제
        theme: ThemeData(
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Colors.black,
            ),
            iconTheme: IconThemeData(color: Colors.black),
            appBarTheme: AppBarTheme(
              elevation: 1, //앱 바 그림자
              color:Colors.white,
              titleTextStyle: TextStyle(color:Colors.black, fontSize: 20),
              actionsIconTheme: IconThemeData(color:Colors.black),
            ),
            textTheme: TextTheme(
              bodyText2: TextStyle(color:Colors.black),
            )
        ), //이 안에 스타일 다 모아놓는 ThemeData() (그냥 css파일 같은 것임)
        home : const MyApp(),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var list = [1,2,3];
  var Map = {'name':'john', 'age':20}; ///print('name'); <- john 이 불러와 진다.
  var data = [];
  var userImage;


  getData() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if(result.statusCode == 200){ //성공

    } else {

    }
    var result2 = jsonDecode(result.body);
    print('================');
    print(result2);
    print('================');
    print(result2[0]);
    print('================');
    print(result2[0]['likes']); /// 데이터 가져와서 뽑는 법
    print('================');
    setState(() {
      data = result2;
    });
  }

  @override
  void initState(){ //이 위젯이 처음 실행될때 뜨는 곳 (여기에는 async를 못 붙여서 await를 못쓴다. 그래서 위에 따로 함수를 만들어야 함 (getData))
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //shadowColor: Colors.white, // 앱바 그림자 색상
        title : Text("Instagram"),
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: IconButton(
              icon: Icon(Icons.add_box_outlined),
              onPressed: () async {
                var picker = ImagePicker();
                //var image = await picker.pickMultiImage(); // 이미지 여러개
                var image = await picker.pickImage(source: ImageSource.gallery); // 이미지
                //var image = await picker.pickVideo(source: ImageSource.gallery); // 동영상
                //var image = await picker.pickImage(source: ImageSource.camera); // 바로 카메라 띄울 수 있도록

                if (image != null) {
                  setState((){
                    userImage = File(image.path);
                  });
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => Upload(userImage : userImage)),
                );
              },
            ),
          )
        ],
      ),
      body : [Home(data : data), Text('샵페이지')][tab],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false, // 밑에 라벨 안보이게
        showUnselectedLabels: false, // 밑에 라벨 안보이게
        onTap: (i){
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: '샵'),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, this.data}) : super(key: key);
  final data;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var scroll = ScrollController(); // 스크롤 관련
  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      //print(scroll.position.pixels); //내가 얼마나 스트롤 했냐
      //print(scroll.position.maxScrollExtent); //스크롤바 최대 내릴 수 있는 길이
      //print(scroll.position.userScrollDirection); //유저가 어디 방향으로 스크롤 했는지
      if(scroll.position.pixels == scroll.position.maxScrollExtent){
        print('같음');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //데이터에 뭐가 있으면
    if(widget.data.isNotEmpty){
      return ListView.builder(itemCount: 3, controller : scroll, itemBuilder: (c,i){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.data[i]['image']),
            //Image.asset(data[i]['image']),
            Text(widget.data[i]['likes'].toString()),
            Text(widget.data[i]['user']),
            Text(widget.data[i]['content']),
          ],
        );
      });
    } else {
      return Text('로딩중임');
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage}) : super(key: key);
  final userImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(userImage),
            Text('이미지업로드화면'),
            IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)
            ),
          ],
        )
    );

  }
}