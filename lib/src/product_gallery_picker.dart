import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductGalleryPicker extends StatefulWidget {
  int? maxImages;
  int? maxImageSizeInMB;
  String? addImagesTitle;
  Color? primaryColor;
  Color? dottedBorderColor;

  ProductGalleryPicker(this.maxImages, this.addImagesTitle,
      this.maxImageSizeInMB, this.primaryColor, this.dottedBorderColor);

  @override
  State<ProductGalleryPicker> createState() => _ProductGalleryPickerState();
}

class _ProductGalleryPickerState extends State<ProductGalleryPicker> {
  final picker = ImagePicker();
  List<ImageUploadModel> imagesFiles = [];
  List<String> downloadUrls = [];
  int selectedPhoto = 0;

  Future onAddImageClick(int index, bool fromCamera) async {
    if (fromCamera) {
      XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 50,
      );

      File img = File(pickedFile!.path);
      final bytes = img.readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      print('$mb');
      if (mb > widget.maxImageSizeInMB!) {
        final snackBar = SnackBar(
          content: Text(
            "One or more images exceeded the maximum size ${widget.maxImageSizeInMB!}MB",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          ImageUploadModel imageUpload =
              ImageUploadModel(imageFile: File(pickedFile.path), type: 'image');
          if (imagesFiles.isEmpty) {
            imagesFiles.add(imageUpload);

            ImageUploadModel buttonAdd = ImageUploadModel(
                imageFile: File(pickedFile.path), type: 'button');
            imagesFiles.add(buttonAdd);
          } else {
            if (imagesFiles.length == widget.maxImages) {
              imagesFiles.removeAt(widget.maxImages! - 1);
              imagesFiles.add(imageUpload);
            } else {
              imagesFiles.insert(imagesFiles.length - 1, imageUpload);
            }
          }
        });
      }
    } else {
      List<XFile> pickedMultiFiles = await picker.pickMultiImage(
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 50,
      );

      int countFiles = (pickedMultiFiles.length + imagesFiles.length) -
          (widget.maxImages! + 1);
      int stopLoop = countFiles > 0
          ? pickedMultiFiles.length - countFiles
          : pickedMultiFiles.length;
      for (int i = 0; i < stopLoop; i++) {
        File img = File(pickedMultiFiles[i].path);
        final bytes = img.readAsBytesSync().lengthInBytes;
        final kb = bytes / 1024;
        final mb = kb / 1024;

        print('$mb');
        if (mb > widget.maxImageSizeInMB!) {
          final snackBar = SnackBar(
            content: Text(
              "One or more images exceeded the maximum size ${widget.maxImageSizeInMB!}MB",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          setState(() {
            ImageUploadModel imageUpload = ImageUploadModel(
                imageFile: File(pickedMultiFiles[i].path), type: 'image');
            if (imagesFiles.isEmpty) {
              imagesFiles.add(imageUpload);

              ImageUploadModel buttonAdd = ImageUploadModel(
                  imageFile: File(pickedMultiFiles[i].path), type: 'button');
              imagesFiles.add(buttonAdd);
            } else {
              if (imagesFiles.length == widget.maxImages!) {
                imagesFiles.removeAt(widget.maxImages! - 1);
                imagesFiles.add(imageUpload);
              } else {
                imagesFiles.insert(imagesFiles.length - 1, imageUpload);
              }
            }
          });
        }
      }
    }
  }

  void showImagePicker(context, int index) {
    if (imagesFiles.length < (widget.maxImages! + 1)) {
      showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          builder: (BuildContext bc) {
            return Wrap(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(25, 20, 10, 0),
                  child: Text(
                    "${widget.addImagesTitle!}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
                  child: Divider(
                    color: Colors.grey,
                    thickness: 0.8,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: Colors.grey,
                  ),
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    onAddImageClick(index, false);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_camera,
                    color: Colors.grey,
                  ),
                  title: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    onAddImageClick(index, true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  int getImagesLength() {
    if (imagesFiles.length == widget.maxImages! &&
        imagesFiles[widget.maxImages! - 1].type == 'image') {
      return widget.maxImages!;
    } else {
      return imagesFiles.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          (imagesFiles.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(2),
                  child: ElevatedButton(
                    onPressed: () {
                      showImagePicker(context, imagesFiles.length);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.all(0),
                        shadowColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        )),
                    child: DottedBorder(
                      color: widget.dottedBorderColor!,
                      strokeWidth: 2,
                      dashPattern: [10, 8],
                      strokeCap: StrokeCap.round,
                      radius: Radius.circular(15),
                      borderType: BorderType.RRect,
                      child: Container(
                        height: 270,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(13),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Icon(
                                Icons.add_rounded,
                                color: widget.primaryColor!,
                                size: 80,
                              ),
                            ),
                            Text(
                              "${widget.addImagesTitle!}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: widget.primaryColor!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      height: 270,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: FileImage(
                            imagesFiles[selectedPhoto].imageFile!,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: double.infinity,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Container(
                          width: 50,
                          height: 25,
                          margin: EdgeInsets.only(top: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              '${getImagesLength()}/${widget.maxImages!}',
                              style: TextStyle(
                                color: Colors.white,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
          SizedBox(height: imagesFiles.isNotEmpty ? 15 : 0),
          imagesFiles.isNotEmpty
              ? GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 1 / 1,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                  children: imagesFiles
                      .asMap()
                      .map(
                        (i, image) {
                          if (image.type == 'image') {
                            return MapEntry(
                              i,
                              Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    padding: EdgeInsets.all(3),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (image.type == 'image') {
                                          setState(() {
                                            selectedPhoto = i;
                                          });
                                        }
                                      },
                                      child: Card(
                                        elevation: 0,
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: (i == selectedPhoto)
                                                  ? widget.primaryColor!
                                                  : Colors.white,
                                              width: (i == selectedPhoto)
                                                  ? 2.5
                                                  : 0,
                                            )),
                                        child: Image.file(
                                          image.imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (i == 0 &&
                                              imagesFiles.length == 2) {
                                            imagesFiles.clear();
                                          } else {
                                            if (i == selectedPhoto)
                                              selectedPhoto = 0;
                                            if (imagesFiles.length ==
                                                    widget.maxImages! &&
                                                imagesFiles[widget.maxImages! -
                                                            1]
                                                        .type ==
                                                    'image') {
                                              imagesFiles.removeAt(i);

                                              ImageUploadModel buttonAdd =
                                                  ImageUploadModel(
                                                      imageFile: File('path'),
                                                      type: 'button');
                                              imagesFiles.add(buttonAdd);
                                            } else {
                                              imagesFiles.removeAt(i);
                                            }
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        padding: EdgeInsets.all(0),
                                        margin: EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.primaryColor!,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          } else {
                            return MapEntry(
                              i,
                              GestureDetector(
                                onTap: () {
                                  showImagePicker(context, imagesFiles.length);
                                },
                                child: Container(
                                  width: 100,
                                  padding: EdgeInsets.all(3),
                                  child: GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: DottedBorder(
                                        color: widget.dottedBorderColor!,
                                        strokeWidth: 2,
                                        dashPattern: [6, 5],
                                        strokeCap: StrokeCap.round,
                                        radius: Radius.circular(10),
                                        borderType: BorderType.RRect,
                                        child: Center(
                                          child: Icon(
                                            Icons.add_rounded,
                                            color: widget.primaryColor!,
                                            size: 35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )
                      .values
                      .toList(),
                )
              : Container(),
        ],
      ),
    );
  }
}

class ImageUploadModel {
  File? imageFile;

  String? type;

  ImageUploadModel({
    this.imageFile,
    this.type,
  });
}
