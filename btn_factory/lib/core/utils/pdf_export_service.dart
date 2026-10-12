import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<void> exportReportPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    final production = reportData['production'] as Map<String, dynamic>? ?? {};
    final materials = reportData['materials'] as List<dynamic>? ?? [];
    final rejection = reportData['rejection'] as Map<String, dynamic>? ?? {};
    final revenue = reportData['revenue'] as Map<String, dynamic>? ?? {};

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal800,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BUTTON FACTORY',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Production & Analytics Report',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Generated: $formattedDate',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Production Report Section
              _buildSectionHeader('Production Summary'),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Metric', 'Output / Value'],
                data: [
                  ['Completed Orders', '${production['completed_orders'] ?? 0}'],
                  ['Casting Output', '${production['casting_output'] ?? 0} gross qty'],
                  ['Turning Output', '${production['turning_output'] ?? 0} gross qty'],
                  ['Packing Output', '${production['packing_output'] ?? 0} packed qty'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                cellHeight: 24,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                },
              ),
              pw.SizedBox(height: 16),

              // Material Consumption Section
              _buildSectionHeader('Material Consumption'),
              pw.SizedBox(height: 8),
              materials.isEmpty
                  ? pw.Text('No material consumption recorded.', style: const pw.TextStyle(color: PdfColors.grey700))
                  : pw.TableHelper.fromTextArray(
                      headers: ['Material Name', 'Quantity Consumed'],
                      data: materials
                          .map((item) => [
                                item['name'] as String? ?? 'N/A',
                                '${item['quantity'] ?? 0} ${item['unit'] as String? ?? ''}',
                              ])
                          .toList(),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                      cellHeight: 24,
                    ),
              pw.SizedBox(height: 16),

              // Rejection Section
              _buildSectionHeader('Rejection Analysis'),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Metric', 'Value'],
                data: [
                  ['Rejection Rate', '${rejection['rejection_rate'] ?? 0.0}%'],
                  ['Total Output (Packed + Rejected)', '${(rejection['total_packed'] ?? 0) + (rejection['total_rejected'] ?? 0)}'],
                  ['Total Rejected Qty', '${rejection['total_rejected'] ?? 0}'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                cellHeight: 24,
              ),
              pw.SizedBox(height: 16),

              // Revenue Section
              _buildSectionHeader('Revenue Overview'),
              pw.SizedBox(height: 8),
              pw.TableHelper.fromTextArray(
                headers: ['Financial Metric', 'Amount (INR) / Count'],
                data: [
                  ['Total Order Value', 'INR ${revenue['total_revenue'] ?? 0.0}'],
                  ['Completed Orders Count', '${revenue['completed_count'] ?? 0}'],
                  ['Pending Revenue Value', 'INR ${revenue['pending_revenue'] ?? 0.0}'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                cellHeight: 24,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'factory_production_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static Future<void> exportOrderPdf(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    final token = order['token'] as String? ?? 'BTN-ORDER';
    final companyName = order['company_name'] as String? ?? 'N/A';
    final status = order['status'] as String? ?? 'Created';

    final rawMaterials = order['raw_materials'] as List<dynamic>? ?? [];
    final casting = order['casting_process'] as Map<String, dynamic>?;
    final blanking = order['blanking_process'] as Map<String, dynamic>? ??
        (casting != null && (casting['gross_quantity'] != null || casting['rejection_weight'] != null || casting['operator'] != null)
            ? casting
            : null);
    final turning = order['turning_process'] as Map<String, dynamic>?;
    final polish = order['polishing_process'] as Map<String, dynamic>?;
    final packing = order['packing_process'] as Map<String, dynamic>?;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Card
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal800,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PRODUCTION JOB CARD',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Company: $companyName',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 12),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Order Type: ${order['order_type'] ?? 'Production'}',
                          style: const pw.TextStyle(color: PdfColors.teal100, fontSize: 11),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'TOKEN: $token',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Status: $status',
                          style: const pw.TextStyle(color: PdfColors.yellow300, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Product Specifications Table
              _buildSectionHeader('Product Specifications'),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headers: ['Parameter', 'Specification', 'Parameter', 'Specification'],
                data: [
                  ['PO Date', '${order['po_date'] ?? 'N/A'}', 'Dispatch Date', '${order['dispatch_date'] ?? 'N/A'}'],
                  ['Order Type', '${order['order_type'] ?? 'Production'}', 'Casting Type', '${order['casting_type'] ?? 'N/A'}'],
                  ['Sample', '${order['sample'] ?? 'N/A'}', 'Thickness', '${order['thickness'] ?? 'N/A'}'],
                  ['Holes', '${order['holes'] ?? 'N/A'}', 'Box Type', '${order['box_type'] ?? 'N/A'}'],
                  ['Rate', 'INR ${order['rate'] ?? 'N/A'}', 'Quantity', '${order['quantity'] ?? 'N/A'}'],
                  ['Linings', '${order['linings'] ?? 'N/A'}', 'Laser', '${order['laser'] ?? 'N/A'}'],
                  ['Polish Type', '${order['polish_type'] ?? 'N/A'}', 'Packing Option', '${order['packing_option'] ?? 'N/A'}'],
                  ['Status', status, '', ''],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
                cellHeight: 20,
              ),
              pw.SizedBox(height: 14),

              // Department Process Updates
              if (rawMaterials.isNotEmpty) ...[
                _buildSectionHeader('Raw Material Logs'),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: ['Material Name', 'Order Qty', 'Total Available', 'Unit', 'Price (INR)'],
                  data: rawMaterials
                      .map((m) => [
                            '${m['material_name'] ?? 'N/A'}',
                            '${m['quantity'] ?? 'N/A'}',
                            '${m['total_available_quantity'] ?? 'N/A'}',
                            '${m['unit'] ?? ''}',
                            'INR ${m['price'] ?? 'N/A'}',
                          ])
                      .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                  cellHeight: 18,
                ),
                pw.SizedBox(height: 10),
              ],

              if (casting != null) ...[
                _buildSectionHeader('Casting Log'),
                pw.SizedBox(height: 4),
                _buildCastingTable(casting),
                pw.SizedBox(height: 10),
              ],

              if (blanking != null) ...[
                _buildSectionHeader('Blanking Log'),
                pw.SizedBox(height: 4),
                _buildBlankingTable(blanking),
                pw.SizedBox(height: 10),
              ],

              if (turning != null) ...[
                _buildSectionHeader('Turning Log'),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: ['Tool No', 'Inwards Wt (kg)', 'Outward Wt (kg)', 'Gross Qty', 'Blank Thickness', 'M/C No', 'Operator'],
                  data: [
                    [
                      '${turning['tool_no'] ?? turning['art_no'] ?? 'N/A'}',
                      '${turning['inward_weight'] ?? turning['weight'] ?? 'N/A'}',
                      '${turning['outward_weight'] ?? turning['turned_in_kgs'] ?? 'N/A'}',
                      '${turning['gross_quantity'] ?? 'N/A'}',
                      '${turning['blank_thickness'] ?? turning['semi_finish_thickness'] ?? 'N/A'}',
                      '${turning['machine_no'] ?? 'N/A'}',
                      '${turning['operator'] ?? 'N/A'}',
                    ]
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                  cellHeight: 18,
                ),
                pw.SizedBox(height: 10),
              ],

              if (polish != null) ...[
                _buildSectionHeader('Polishing Log'),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: ['Receiving Date', 'Inward Wt (kg)', 'Outward Wt (kg)', 'Gross Qty', 'In Time', 'Out Time', 'Operator', 'Polish Type'],
                  data: [
                    [
                      polish['receiving_date'] != null ? polish['receiving_date'].toString().split('T').first : 'N/A',
                      '${polish['inward_weight'] ?? polish['weight'] ?? 'N/A'}',
                      '${polish['outward_weight'] ?? 'N/A'}',
                      '${polish['gross_quantity'] ?? 'N/A'}',
                      polish['feeding_time'] != null ? polish['feeding_time'].toString().split('T').last.split('.').first : 'N/A',
                      polish['out_time'] != null ? polish['out_time'].toString().split('T').last.split('.').first : 'N/A',
                      '${polish['operator'] ?? 'N/A'}',
                      '${polish['polish_type'] ?? 'N/A'}',
                    ]
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                  cellHeight: 18,
                ),
                pw.SizedBox(height: 10),
              ],

              if (packing != null) ...[
                _buildSectionHeader('Packing Log'),
                pw.SizedBox(height: 4),
                pw.TableHelper.fromTextArray(
                  headers: ['Receiving Date', 'Inward Wt (kg)', 'Outward Wt (kg)', '1 Gross Wt (kg)', 'In Gross', 'Packed Qty', 'Rejection', 'Operator'],
                  data: [
                    [
                      packing['receiving_date'] != null ? packing['receiving_date'].toString().split('T').first : 'N/A',
                      '${packing['inward_weight'] ?? packing['weight'] ?? 'N/A'}',
                      '${packing['outward_weight'] ?? 'N/A'}',
                      '${packing['one_gross_weight'] ?? 'N/A'}',
                      '${packing['in_gross'] ?? 'N/A'}',
                      '${packing['packed_qty'] ?? 'N/A'}',
                      '${packing['rejected_qty'] ?? 'N/A'}',
                      '${packing['operator'] ?? 'N/A'}',
                    ]
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
                  cellHeight: 18,
                ),
              ],
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'order_${token}_jobcard.pdf',
    );
  }

  static pw.Widget _buildCastingTable(Map<String, dynamic> casting) {
    final isRod = (casting['casting_type'] as String?)?.toLowerCase() == 'rod';
    return pw.TableHelper.fromTextArray(
      headers: isRod
          ? ['Sheet', 'Line', 'Total (Resin)', 'Blank Thickness', 'Remarks', 'Date', 'No. of ROD', 'Gross (Approx)', 'Operator']
          : ['Casting Type', 'Date', 'Total RM (kg)', 'Sheets', 'Thickness', 'Remarks'],
      data: [
        isRod
            ? [
                '${casting['sheet'] ?? 'N/A'}',
                '${casting['line'] ?? 'N/A'}',
                '${casting['total_resin'] ?? 'N/A'}',
                '${casting['blank_thickness'] ?? casting['thickness'] ?? 'N/A'}',
                '${casting['remarks'] ?? 'None'}',
                casting['date_of_casting'] != null ? casting['date_of_casting'].toString().split('T').first : 'N/A',
                '${casting['no_of_rods'] ?? 'N/A'}',
                '${casting['gross_quantity'] ?? 'N/A'}',
                '${casting['operator'] ?? 'N/A'}',
              ]
            : [
                '${casting['casting_type'] ?? 'Sheet'}',
                casting['date_of_casting'] != null ? casting['date_of_casting'].toString().split('T').first : 'N/A',
                '${casting['total_weight'] ?? 'N/A'}',
                '${casting['no_of_sheets'] ?? 'N/A'}',
                '${casting['blank_thickness'] ?? casting['thickness'] ?? 'N/A'}',
                '${casting['remarks'] ?? 'None'}',
              ]
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellHeight: 18,
    );
  }

  static pw.Widget _buildBlankingTable(Map<String, dynamic> blanking) {
    return pw.TableHelper.fromTextArray(
      headers: ['Weight (kg)', 'In Gross', 'Rejection (kg)', 'Operator', 'Blank Thickness', 'Remarks'],
      data: [
        [
          '${blanking['weight'] ?? 'N/A'}',
          '${blanking['gross_quantity'] ?? 'N/A'}',
          '${blanking['rejection_weight'] ?? '0'}',
          '${blanking['operator'] ?? 'N/A'}',
          '${blanking['blank_thickness'] ?? 'N/A'}',
          '${blanking['remarks'] ?? 'None'}',
        ]
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
      cellHeight: 18,
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border(left: pw.BorderSide(color: PdfColors.teal800, width: 3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
      ),
    );
  }
}
