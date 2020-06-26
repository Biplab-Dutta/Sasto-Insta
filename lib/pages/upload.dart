import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String postId = Uuid().v4();
  final postsRef = Firestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  PickedFile pickedFile;
  final picker = ImagePicker();
  bool isUploading = false;
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  openGallery() async {
    Navigator.pop(context);
    pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    setState(
      () {
        this.pickedFile = pickedFile;
      },
    );
  }

  openCamera() async {
    Navigator.pop(context);
    pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
      imageQuality: 70,
    );

    setState(
      () {
        this.pickedFile = pickedFile;
      },
    );
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Upload Post!'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo with Camera'),
                onPressed: () {
                  openCamera();
                },
              ),
              SimpleDialogOption(
                child: Text('Photo from Gallery'),
                onPressed: () {
                  openGallery();
                },
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Container buildUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: RaisedButton(
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.deepOrange,
              onPressed: () {
                selectImage(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      pickedFile = null;
    });
  }

  Future<String> uploadImage(fileImage) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(fileImage);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    setState(
      () {
        isUploading = false;
        pickedFile = null;
        postId = Uuid().v4();
      },
    );
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    final snackBar = SnackBar(
      content: Text('Image uploaded in Firestore Storage'),
    );

    Scaffold.of(context).showSnackBar(snackBar);
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .collection('posts')
        .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "location": location,
      "description": description,
      "timestamp": DateTime.now(),
    });
  }

  handleSubmit() async {
    final File file = File(pickedFile.path);
    setState(
      () {
        isUploading = true;
      },
    );
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);
    locationController.clear();
    captionController.clear();
  }

  Scaffold uploadPost() {
    final File file = File(pickedFile.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Caption Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            clearImage();
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            onPressed: isUploading ? null : () => handleSubmit(),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "What is your current location?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use my current location.",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {},
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pickedFile == null ? buildUploadScreen() : uploadPost();
  }
}
