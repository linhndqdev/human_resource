import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class ItemPDFFileDefaultGroup extends StatefulWidget {
  final String titlePdf;
  final String linkPdf;

  ItemPDFFileDefaultGroup({this.titlePdf, this.linkPdf});

  @override
  _ItemPDFFileDefaultGroupState createState() =>
      _ItemPDFFileDefaultGroupState();
}

class _ItemPDFFileDefaultGroupState extends State<ItemPDFFileDefaultGroup>
    with SingleTickerProviderStateMixin {
  String path;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/'+widget.titlePdf);
  }

  Future<File> writeCounter(Uint8List stream) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsBytes(stream);
  }

  Future<bool> existsFile() async {
    final file = await _localFile;
    return file.exists();
  }

  Future<Uint8List> fetchPost() async {
    final response = await http.get(widget.linkPdf);
    final responseJson = response.bodyBytes;

    return responseJson;
  }

  void loadPdf() async {
    await writeCounter(await fetchPost());
    await existsFile();
    path = (await _localFile).path;

    if (!mounted) return;

    setState(() {});
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero,(){
      loadPdf();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(path);
    return Container(
      constraints: BoxConstraints(minWidth: 810.5.w),
      color: Color(0xff323639),
      margin: EdgeInsets.only(
        top: 16.1.h,
        bottom: 32.5.h,
        left: 22.5.w,
        right: 22.w,
      ),
      padding: EdgeInsets.only(
        top: 14.6.h,
        bottom: 6.4.h,
        left: 5.6.w,
        right: 6.7.w,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 27.2.w, bottom: 28.3.h),
            child: Text(
              widget.titlePdf,
              style: TextStyle(
                  fontFamily: "Roboto-Bold",
                  fontSize: 18.sp,
                  color: Colors.white),
            ),
          ),
          if (path != null)
           Stack(
             children: <Widget>[
               Container(
                 color: Colors.white,
                 height: 469.2.h,
                 width: 810.w,
                 child: PdfViewer(
                   filePath: path,
                 ),
               ),
               Container(
                 color: Colors.transparent,
                 height: 469.2.h,
                 width: 810.w,
               ),
             ],
           )
          else
            Container(
              color: Colors.white,
              height: 469.2.h,
              width: 810.w,
            ),
        ],
      ),
    );
  }
}
