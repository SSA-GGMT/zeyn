import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../api/pocketbase.dart';
import '../../components/student_qr_login_screen.dart';
import '../logger.dart';

Future<Uint8List> createPDF(List<StudentQrModel> accounts, String title, String courseID) async {
  final pdf = pw.Document(
    pageMode: PdfPageMode.fullscreen,
    author: 'Sportslogger',
    creator: pb.authStore.record?.data['email'],
  );

  logger.d('Creating PDF with ${accounts.length} QR codes');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header:
          (context) => pw.Text(
            title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
      footer: (context) => pw.SizedBox(
        width: 600,
        child: pw.Row(
            children: [
              pw.Column(
                  children: [
                    pw.Text('Nur für den internen gebrauch'.toUpperCase(), style: pw.TextStyle(fontSize: 8.0, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      'Generiert von ${pb.authStore.record?.data['krz']} ${pb.authStore.record?.data['email']}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text('${pb.authStore.record?.data['school']}:${pb.authStore.record?.id}:$courseID', style: pw.TextStyle(fontSize: 6.0, font: pw.Font.courier())),
                  ]
              ),
              pw.Spacer(),
              pw.Column(
                  children: [
                    pw.Text(
                      'Seite ${context.pageNumber} von ${context.pagesCount}',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      DateTime.now().toLocal().toString(),
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  ]
              )
            ]
        )
      ),
      build: (context) {
        final chunks = splitIntoChunks(accounts, 3);
        return chunks
            .map(
              (chunk) => pw.Padding(
                padding: pw.EdgeInsets.only(top: 2.0),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      chunk
                          .map(
                            (e) => pw.Container(
                              padding: pw.EdgeInsets.all(2.0),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.black,
                                  width: 1.0,
                                ),
                              ),
                              child: pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.BarcodeWidget(
                                    data: e.createLoginToken(),
                                    barcode: pw.Barcode.qrCode(),
                                    width: 150,
                                    height: 150,
                                    padding: pw.EdgeInsets.all(4.0),
                                  ),
                                  pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.SizedBox(
                                        width: 150,
                                        child: pw.Text(
                                          '${e.firstName} ${e.secondName}',
                                          softWrap: true,
                                          style: pw.TextStyle(fontSize: 12),
                                        )
                                      ),
                                      pw.Text(
                                        e.id,
                                        style: pw.TextStyle(fontSize: 8),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            )
            .toList();
      },
    ),
  );

  return await pdf.save();
}

List<List<T>> splitIntoChunks<T>(List<T> list, int chunkSize) {
  List<List<T>> chunks = [];
  for (int i = 0; i < list.length; i += chunkSize) {
    int end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
    chunks.add(list.sublist(i, end));
  }
  return chunks;
}
