import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_tracker/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore services
  FirestoreService firestoreService = FirestoreService();
  final TextEditingController controller = TextEditingController();

  void noteBox(String? docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter note here",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addNote(controller.text);
              } else {
                firestoreService.updateNote(docID, controller.text);
              }

              controller.clear();
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => noteBox(null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // Check if there's an error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Check if data is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if data is available
          if (snapshot.hasData && snapshot.data != null) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // Get note from each document
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                // Display it
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => noteBox(docID),
                          icon: Icon(Icons.edit)),
                      IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: Icon(Icons.delete)),
                    ],
                  ),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete),
                  //   onPressed: () {
                  //     // firestoreService.deleteNote(docID);
                  //   },
                );
              },
            );
          } else {
            // Handle case when no data is available
            return const Center(child: Text("No notes available"));
          }
        },
      ),
    );
  }
}
