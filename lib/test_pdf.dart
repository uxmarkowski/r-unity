import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';


class PdfTest extends StatefulWidget {
  const PdfTest({Key? key}) : super(key: key);

  @override
  State<PdfTest> createState() => _PdfTestState();
}

class _PdfTestState extends State<PdfTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("sss"),),
      body: Center(
        child: Container(
          // height: 524,
          // color: Colors.red,
          child: PDF().cachedFromUrl(
            'https://firebasestorage.googleapis.com/v0/b/avit-827db.appspot.com/o/GaoYang%20каталог.pdf?alt=media&token=d00c4eb5-9f57-4845-88e6-d890c8d7209e',
            placeholder: (progress) => Center(child: Text('$progress %')),
            errorWidget: (error) => Center(child: Text(error.toString())),
          ),
        ),
      ),
    );
  }
}
