import 'package:books_store/data/seed_books_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// This is a one-time use file to upload books data to Firebase
// After using this file, you should delete it from your project

class UploadBooksDataScreen extends StatefulWidget {
  const UploadBooksDataScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadBooksDataScreenState createState() => _UploadBooksDataScreenState();
}

class _UploadBooksDataScreenState extends State<UploadBooksDataScreen> {
  bool _isUploading = false;
  String _status = 'Ready to upload';
  final TextEditingController _secondCollectionController =
      TextEditingController();
  bool _useSecondCollection = false;

  @override
  void dispose() {
    _secondCollectionController.dispose();
    super.dispose();
  }

  Future<void> _uploadBooksData() async {
    setState(() {
      _isUploading = true;
      _status = 'Uploading books data...';
    });

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final List<String> collectionsToUpload = ['books'];

      // Add second collection if specified
      if (_useSecondCollection && _secondCollectionController.text.isNotEmpty) {
        collectionsToUpload.add(_secondCollectionController.text.trim());
      }

      // Process each collection
      for (final collectionName in collectionsToUpload) {
        // Delete all existing data in the collection
        setState(() {
          _status = 'Cleaning existing data in $collectionName...';
        });
        final QuerySnapshot snapshot =
            await firestore.collection(collectionName).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        // Add each book to Firestore
        setState(() {
          _status = 'Uploading ${seedBooks.length} books to $collectionName...';
        });

        int count = 0;
        for (var book in seedBooks) {
          await firestore.collection(collectionName).add(book);
          count++;
          if (count % 5 == 0) {
            setState(() {
              _status =
                  'Uploaded $count/${seedBooks.length} books to $collectionName...';
            });
          }
        }
      }

      setState(() {
        final String collections = collectionsToUpload.join(' and ');
        _status =
            'Success! ${seedBooks.length} books uploaded to $collections collections.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error uploading books data: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Books Data'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _useSecondCollection,
                    onChanged: (value) {
                      setState(() {
                        _useSecondCollection = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _secondCollectionController,
                      decoration: const InputDecoration(
                        labelText: 'Second Collection Name',
                        hintText: 'E.g. menu_items',
                        enabled: true,
                      ),
                      enabled: _useSecondCollection,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadBooksData,
                child:
                    Text(_isUploading ? 'Uploading...' : 'Upload Books Data'),
              ),
              const SizedBox(height: 40),
              const Text(
                'IMPORTANT: After using this screen, delete this file from your project.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
