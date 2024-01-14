import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:story_app_preferences/db/db_helper.dart';
import 'package:story_app_preferences/model/model.dart';
import 'package:story_app_preferences/page/camera_screen.dart';
import 'package:story_app_preferences/page/detail_page.dart';
import 'package:story_app_preferences/provider/story_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;
  bool _isOpen = false;

  void _refreshData() async {
    final data = await SqlHelper.getAllStory();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _refreshData();
    super.initState();
  }

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _descriptionControllerEdit =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _searchControllerEdit = TextEditingController();

// add data
  Future<void> _addData(StoryResult data) async {
    final provider = context.read<StoryProvider>();
    final imagePath = provider.imagePath;

    if (imagePath == null) {
      return;
    }

    await SqlHelper.createStory(data);

    _refreshData();

    _descriptionController.text = '';
    provider.setImagePath(null);
  }

  // update data
  Future<void> _updadateData(StoryResult data, int id) async {
    final imagePath = context.read<StoryProvider>().imagePath;
    await SqlHelper.updateStory(data, id);
    _refreshData();
  }

  // delete data
  void _deleteData(int id) async {
    await SqlHelper.deleteStory(id);

    Get.snackbar('Berhasil', 'Berhasil menghapus Story');
  }

  // search data
  void _searchData() async {
    final query = _searchController.text;
    final searchStory = await SqlHelper.searchStory(query);

    setState(() {
      _allData = searchStory;
    });
  }

  // gallery preview
  void _onGalleryView() async {
    final provider = context.read<StoryProvider>();
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
      provider.notifyListeners();
    }
  }

  void _onCustomCameraView() async {
    final provider = context.read<StoryProvider>();

    final cameras = await availableCameras();

    final XFile? resultImageFile =
        await Get.to(() => CameraScreen(cameras: cameras));

    if (resultImageFile != null) {
      provider.setImageFile(resultImageFile);
      provider.setImagePath(resultImageFile.path);
    }
  }

  Widget showCreateSheets() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            context.watch<StoryProvider>().imagePath == null
                ? const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 100,
                    ),
                  )
                : _showImage(),
            const Gap(10),
            Row(
              children: [
                IconButton(
                  onPressed: () => _onGalleryView(),
                  icon: const Icon(Icons.photo),
                ),
                IconButton(
                  onPressed: () => _onCustomCameraView(),
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(label: Text('Description')),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final provider = context.read<StoryProvider>();

                  await _addData(StoryResult(
                      description: _descriptionController.text,
                      imagePath: provider.imagePath!));

                  _descriptionController.text = '';
                  // provider.imagePath = null;

                  setState(() {
                    _isOpen = false;
                  });
                },
                child: const Text('Add Story'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('story app'),
        actions: const [],
      ),
      body: _isOpen ? showCreateSheets() : _buildList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isOpen = !_isOpen;
          });
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _showImage() {
    final imagePath = context.read<StoryProvider>().imagePath;

    if (imagePath != null && File(imagePath).existsSync()) {
      return SizedBox(
        width: 300,
        height: 300,
        child: Image.file(
          File(imagePath), // Convert String path to File
          fit: BoxFit.contain,
          width: 180.0,
          height: 180.0,
        ),
      );
    } else {
      return const Text('No Image'); // Placeholder or handle differently
    }
  }

  Widget _buildList(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _allData.length,
      itemBuilder: (context, index) {
        final data = _allData[index];
        return Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              Get.to(() => DetailPage(data: data));
            },
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(data['imagePath'])),
                          fit: BoxFit.cover, // Set the BoxFit to cover
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              _deleteData(data['id']);
                              _refreshData();
                            },
                            icon: Icon(
                              Icons.delete,
                              color: white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      data['description'],
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color white = Colors.white;
}
