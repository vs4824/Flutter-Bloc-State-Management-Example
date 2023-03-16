import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

var url = "https://jsonplaceholder.typicode.com/posts";

class JsonModel {
  JsonModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });
  late final int userId;
  late final int id;
  late final String title;
  late final String body;

  JsonModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
  }
}

class DioService {
  Future<dynamic> getMethod(String url) async {
    Dio dio = Dio();

    return await dio
        .get(url,
        options: Options(responseType: ResponseType.json, method: "GET"))
        .then((response) {
      return response;
    });
  }
}

class FetchCubit extends Cubit<List<JsonModel?>?> {
  FetchCubit() : super(null);

  List<JsonModel> finalData = [];

  loadData() async {
    try {
      var response = await DioService().getMethod(url);
      if (response.statusCode == 200) {
        response.data.forEach(
              (element) {
            finalData.add(JsonModel.fromJson(element));
          },
        );
        emit(finalData);
      } else {
        debugPrint("Some Error Happened");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class FetchData extends StatefulWidget {
  const FetchData({super.key});

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  late FetchCubit fetchCubit;

  @override
  void initState() {
    fetchCubit = FetchCubit();
    super.initState();
  }

  @override
  void dispose() {
    fetchCubit.close();
    super.dispose();
  }

  Widget text(String text) => Center(
    child: Text(
      text,
      style: const TextStyle(color: Colors.black),
    ),
  );

  @override
  Widget build(BuildContext context) {
    fetchCubit.loadData();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 230, 255),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Flutter Bloc State Management Example",style: TextStyle(
          fontSize: 18
        ),),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<List<JsonModel?>?>(
          stream: fetchCubit.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return text("None");
              case ConnectionState.waiting:
                return LoadingAnimationWidget.halfTriangleDot(
                  size: 35,
                  color: Colors.deepPurpleAccent,
                );

              case ConnectionState.active:
                return RefreshIndicator(
                  onRefresh: () => fetchCubit.loadData(),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      var currentItem = fetchCubit.finalData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 5),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Center(
                                child: Text(currentItem.id.toString()),
                              ),
                            ),
                            title: Text(
                              currentItem.title.toUpperCase(),
                            ),
                            subtitle: Text(
                              currentItem.body,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              case ConnectionState.done:
                return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}