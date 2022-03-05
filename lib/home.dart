import 'package:flutter/material.dart';
import 'package:sqlite/constant.dart';
import 'package:sqlite/sql_helper.dart';

final TextEditingController _titleController = TextEditingController();
final TextEditingController _descController = TextEditingController();

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //All items
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  //Method used to fetch all data from the database
  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    //Loads the notes when the app starts
    _refreshItems();
  }

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void displayForm(int? id) async {
    if (id != null) {
      final existingItem = _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingItem['title'];
      _descController.text = existingItem['description'];

      showModalBottomSheet(
          context: context,
          builder: (_) {
            return Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () async {
                        //Save new item
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                        //clear the text fields
                        _titleController.text = '';
                         _descController.text = '';

                         //close the bottom sheet modal
                         Navigator.of(context).pop();

                      },
                      child: Text(id == null ? "Create New" : "Update"))
                ],
              ),
            );
          });
    }
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text, _descController.text);
    _refreshItems();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text, _descController.text);
    _refreshItems();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteItems(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted Successfully'),
      )
    );
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoxedSrc'),
        backgroundColor: darkColor,
      ),
      body: _isLoading
        ? const Center(
              child: CircularProgressIndicator(),
          ) 
        : ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index)=> 
          Card(
            color: accentColor,
            margin: const EdgeInsets.all(15.0),
            child: ListTile(
              
            ),
          )
          ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: darkColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
