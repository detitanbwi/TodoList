import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Todo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List activities = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // DatabaseHelper().resetDatabase();
    DatabaseHelper().getActivities().then((activityList) {
      setState(() => activities = activityList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return Card(
              child: InkWell(
                // Use InkWell for ripple effect
                onTap: () async {
                  // Handle card tap (excluding checkbox)
                  print(
                    'Card tapped for activity: ${activities[index]['title']}',
                  );

                  final makeChanges = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ActivityDetail(activity: activities[index]),
                    ),
                  );
                  // ignore: unrelated_type_equality_checks
                  if (makeChanges == true) {
                    DatabaseHelper().getActivities().then((activityList) {
                      setState(() => activities = activityList);
                    });
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activities[index]['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(activities[index]['description']),
                          ],
                        ),
                      ),
                    ),
                    Checkbox(
                      value: activities[index]['done'] == 1,
                      onChanged: (bool? value) {
                        setState(() {
                          activities[index]['done'] = value == true ? 1 : 0;
                        });
                        // Update the database
                        DatabaseHelper().updateActivity(
                          activities[index]['id'],
                          value == true ? 1 : 0,
                        );
                        // Refresh the UI
                        DatabaseHelper().getActivities().then((activityList) {
                          setState(() => activities = activityList);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Make the callback async
          final result = await Navigator.push(
            // Await the result
            context,
            MaterialPageRoute(builder: (context) => const CreateActivity()),
          );
          if (result == true) {
            // Check if result indicates new data
            DatabaseHelper().getActivities().then((activityList) {
              setState(
                () => activities = activityList,
              ); // Update the list and UI
            });
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CreateActivity extends StatefulWidget {
  const CreateActivity({super.key});

  @override
  State<CreateActivity> createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivity> {
  String title = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Activity'),
          backgroundColor: Colors.purple,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
            ),

            MaterialButton(
              child: Text('Create', style: TextStyle(color: Colors.white)),
              onPressed: () {
                DatabaseHelper().insertActivity({
                  'title': title,
                  'description': description,
                });
                Navigator.pop(context, true);
              },
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityDetail extends StatelessWidget {
  // const ActivityDetail({super.key});
  final Map<String, dynamic> activity;
  const ActivityDetail({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activity Detail'),
          backgroundColor: Colors.purple,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              activity['title'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 10),
            Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              activity['description'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            Row(
              children: [
                Card(
                  child: InkWell(
                    onTap: () {
                      DatabaseHelper().deleteActivity(activity['id']);
                      Navigator.pop(context, true);
                      
                    },
                    child: Container(
                      color: Colors.red,
                      width: 100,
                      height: 40,
                      child: Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
