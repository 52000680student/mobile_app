import 'package:flutter/material.dart';
import '../../../../core/utils/printer_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../l10n/generated/app_localizations.dart';

class BluetoothDeviceSelectionDialog extends StatefulWidget {
  final PrinterService printerService;
  final Function(String address) onDeviceSelected;

  const BluetoothDeviceSelectionDialog({
    super.key,
    required this.printerService,
    required this.onDeviceSelected,
  });

  @override
  State<BluetoothDeviceSelectionDialog> createState() =>
      _BluetoothDeviceSelectionDialogState();
}

class _BluetoothDeviceSelectionDialogState
    extends State<BluetoothDeviceSelectionDialog> {
  List<BluetoothDevice> _pairedDevices = [];
  List<BluetoothDevice> _discoveredDevices = [];
  bool _isDiscovering = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadDevices();
  }

  Future<void> _checkPermissionsAndLoadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if Bluetooth permissions are granted
      final hasPermissions =
          await widget.printerService.checkBluetoothPermissions();

      if (!hasPermissions) {
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.bluetoothPermissionRequired;
          _isLoading = false;
        });
        return;
      }

      // Load paired devices
      await _loadPairedDevices();
    } catch (e) {
      AppLogger.error('Error checking Bluetooth permissions: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.bluetoothConnectionError;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPairedDevices() async {
    try {
      final devices = await widget.printerService.getPairedBluetoothDevices();
      setState(() {
        _pairedDevices = devices;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading paired devices: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.bluetoothConnectionError;
        _isLoading = false;
      });
    }
  }

  Future<void> _discoverDevices() async {
    setState(() {
      _isDiscovering = true;
      _discoveredDevices.clear();
      _errorMessage = null;
    });

    try {
      final devices = await widget.printerService.discoverBluetoothDevices();
      setState(() {
        _discoveredDevices = devices;
        _isDiscovering = false;
      });
    } catch (e) {
      AppLogger.error('Error discovering devices: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.bluetoothConnectionError;
        _isDiscovering = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await widget.printerService.requestBluetoothPermissions();
      // Wait a bit for permissions to be processed
      await Future.delayed(const Duration(milliseconds: 500));
      _checkPermissionsAndLoadDevices();
    } catch (e) {
      AppLogger.error('Error requesting Bluetooth permissions: $e');
    }
  }

  Widget _buildDeviceItem(BluetoothDevice device) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: device.isPaired ? Colors.blue : Colors.grey,
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.address),
            const SizedBox(height: 2),
            Text(
              device.isPaired ? l10n.paired : l10n.unpaired,
              style: TextStyle(
                color: device.isPaired ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            widget.onDeviceSelected(device.address);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.connect),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (_errorMessage == l10n.bluetoothPermissionRequired)
            ElevatedButton(
              onPressed: _requestPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.enablePermissions),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.bluetooth,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.selectBluetoothDevice,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Error message
            if (_errorMessage != null)
              Expanded(child: _buildErrorWidget())
            else ...[
              // Loading indicator
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Paired devices section
                        if (_pairedDevices.isNotEmpty) ...[
                          Text(
                            l10n.pairedDevices,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._pairedDevices.map(_buildDeviceItem),
                          const SizedBox(height: 16),
                        ],

                        // Discover devices section
                        Row(
                          children: [
                            Text(
                              l10n.bluetoothDevices,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed:
                                  _isDiscovering ? null : _discoverDevices,
                              icon: _isDiscovering
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                              label: Text(
                                _isDiscovering
                                    ? l10n.discovering
                                    : l10n.discoverDevices,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Discovered devices
                        if (_discoveredDevices.isNotEmpty)
                          ..._discoveredDevices.map(_buildDeviceItem)
                        else if (!_isDiscovering && _discoveredDevices.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                l10n.noDevicesFound,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],

            // Bottom actions
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
