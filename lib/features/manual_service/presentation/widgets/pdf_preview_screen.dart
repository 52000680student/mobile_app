import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/utils/printer_service.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/manual_service_bloc.dart';
import '../bloc/manual_service_event.dart';
import 'bluetooth_device_selection_dialog.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName;
  final String? sampleName;

  const PdfPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
    this.sampleName,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late final PrinterService _printerService;

  bool _isConnectingPrinter = false;
  bool _isPrinting = false;
  String? _printerAddress;

  @override
  void initState() {
    super.initState();
    _printerService = PrinterService();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _showPrinterConnectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.connectPrinter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.wifi, color: theme.primaryColor),
              title: Text(l10n.tcp),
              subtitle: Text(l10n.printerAddress),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).pop();
                _showTcpConnectionDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.bluetooth, color: theme.primaryColor),
              title: Text(l10n.bluetooth),
              subtitle: Text(l10n.bluetoothDevices),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).pop();
                _showBluetoothConnectionDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showTcpConnectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController addressController = TextEditingController();
    final TextEditingController portController =
        TextEditingController(text: '9100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.connectPrinter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: l10n.printerAddress,
                hintText: '192.168.1.100',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: InputDecoration(
                labelText: l10n.printerPort,
                hintText: '9100',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final address = addressController.text.trim();
              final port = int.tryParse(portController.text.trim()) ?? 9100;

              if (address.isNotEmpty) {
                Navigator.of(context).pop();
                await _connectToPrinter(address, port);
              }
            },
            child: Text(l10n.connect),
          ),
        ],
      ),
    );
  }

  void _showBluetoothConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => BluetoothDeviceSelectionDialog(
        printerService: _printerService,
        onDeviceSelected: (address) async {
          await _connectToBluetoothPrinter(address);
        },
      ),
    );
  }

  Future<void> _connectToPrinter(String address, int port) async {
    setState(() {
      _isConnectingPrinter = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final success = await _printerService.connectPrinter(address, port: port);

      if (success) {
        setState(() {
          _printerAddress = address;
        });
        ToastService.showSuccess(context, l10n.printerConnected);
      } else {
        ToastService.showError(context, l10n.printerConnectionFailed);
      }
    } catch (e) {
      AppLogger.error('Error connecting to printer: $e');
      ToastService.showError(context, l10n.printerConnectionError);
    } finally {
      setState(() {
        _isConnectingPrinter = false;
      });
    }
  }

  Future<void> _connectToBluetoothPrinter(String address) async {
    setState(() {
      _isConnectingPrinter = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final success = await _printerService.connectBluetoothPrinter(address);

      if (success) {
        setState(() {
          _printerAddress = address;
        });
        ToastService.showSuccess(context, l10n.printerConnected);
      } else {
        ToastService.showError(context, l10n.bluetoothConnectionFailed);
      }
    } catch (e) {
      AppLogger.error('Error connecting to Bluetooth printer: $e');
      ToastService.showError(context, l10n.bluetoothConnectionError);
    } finally {
      setState(() {
        _isConnectingPrinter = false;
      });
    }
  }

  Future<void> _printPdf() async {
    if (!_printerService.isConnected) {
      _showPrinterConnectionDialog();
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      // Check printer status first
      final isReady = await _printerService.isPrinterReady();
      if (!isReady) {
        final status = await _printerService.getPrinterStatus();
        String statusMessage = l10n.printerNotReady;

        switch (status) {
          case PrinterStatus.coverOpen:
            statusMessage = l10n.printerCoverOpen;
            break;
          case PrinterStatus.paperEmpty:
            statusMessage = l10n.printerPaperEmpty;
            break;
          case PrinterStatus.printerError:
            statusMessage = l10n.printerError;
            break;
          default:
            statusMessage = l10n.printerNotReady;
        }

        ToastService.showError(context, statusMessage);
        return;
      }

      // Print the PDF
      final success = await _printerService.printPdf(widget.pdfBytes);

      if (success) {
        ToastService.showSuccess(context, l10n.printSuccess);
        // Add print success event to bloc
        context.read<ManualServiceBloc>().add(const PrintSuccessEvent());
      } else {
        ToastService.showError(context, l10n.printFailed);
      }
    } catch (e) {
      AppLogger.error('Error printing PDF: $e');
      ToastService.showError(context, l10n.printError);
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  Future<void> _disconnectPrinter() async {
    await _printerService.disconnectPrinter();
    setState(() {
      _printerAddress = null;
    });
    ToastService.showSuccess(
        context, AppLocalizations.of(context)!.printerDisconnected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sampleName ?? l10n.barcodePreview),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_printerService.isConnected)
            IconButton(
              onPressed: _disconnectPrinter,
              icon: const Icon(Icons.bluetooth_disabled),
              tooltip: l10n.disconnect,
            ),
        ],
      ),
      // Add floating action button temporarily to test
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _printerService.isConnected
            ? _printPdf
            : _showPrinterConnectionDialog,
        icon: Icon(_printerService.isConnected ? Icons.print : Icons.bluetooth),
        label: Text(_printerService.isConnected ? l10n.print : l10n.connect),
        backgroundColor:
            _printerService.isConnected ? Colors.green : theme.primaryColor,
      ),
      body: Column(
        children: [
          // PDF Viewer
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SfPdfViewer.memory(
                  widget.pdfBytes,
                  controller: _pdfViewerController,
                  enableDoubleTapZooming: true,
                  enableTextSelection: false,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  canShowPaginationDialog: false,
                ),
              ),
            ),
          ),

          // Bottom actions - Add SafeArea to ensure visibility
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
                // Add shadow to make it more visible
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Connection status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _printerService.isConnected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth_disabled,
                              color: _printerService.isConnected
                                  ? Colors.green
                                  : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _printerService.isConnected
                                    ? '${l10n.printerConnected} (${_printerService.connectionType == ConnectionType.bluetooth ? l10n.bluetooth : l10n.tcp})'
                                    : l10n.printerDisconnected,
                                style: TextStyle(
                                  color: _printerService.isConnected
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (_printerAddress != null)
                          Text(
                            _printerAddress!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Connect button
                  if (!_printerService.isConnected)
                    ElevatedButton.icon(
                      onPressed: _isConnectingPrinter
                          ? null
                          : _showPrinterConnectionDialog,
                      icon: _isConnectingPrinter
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bluetooth),
                      label: Text(l10n.connect),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),

                  // Print button
                  if (_printerService.isConnected)
                    ElevatedButton.icon(
                      onPressed: _isPrinting ? null : _printPdf,
                      icon: _isPrinting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print),
                      label: Text(l10n.print),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
