import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:application_medicines/medication.dart';

class PdfExporter {
  static Future<void> exportMedicationsToPdf(List<Medication> medications) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Lista de Medicamentos',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              ...medications.map((med) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(
                  '- ${med.name} | Dosis: ${med.dosage} | Hora: ${med.time.hour}:${med.time.minute.toString().padLeft(2, '0')}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              )),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
