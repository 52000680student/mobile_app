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
  bool _isRefreshingPaired = false;
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

  Future<void> _refreshPairedDevices() async {
    setState(() {
      _isRefreshingPaired = true;
      _errorMessage = null;
    });

    try {
      final devices = await widget.printerService.getPairedBluetoothDevices();
      setState(() {
        _pairedDevices = devices;
        _isRefreshingPaired = false;
      });
    } catch (e) {
      AppLogger.error('Error refreshing paired devices: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.bluetoothConnectionError;
        _isRefreshingPaired = false;
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Device icon
            Icon(
              Icons.bluetooth,
              color: device.isPaired ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),

            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    device.name.isNotEmpty
                        ? device.name
                        : 'Thiết bị không xác định',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: device.isPaired
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      device.isPaired ? l10n.paired : l10n.unpaired,
                      style: TextStyle(
                        color: device.isPaired ? Colors.blue : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Connect button
            ElevatedButton(
              onPressed: () {
                widget.onDeviceSelected(device.address);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                l10n.connect,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minHeight: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bluetooth,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.selectBluetoothDevice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _errorMessage != null
                    ? _buildErrorWidget()
                    : _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Paired devices section
                              if (_pairedDevices.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        "Thiết bị đã kết nối",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _isRefreshingPaired
                                          ? null
                                          : _refreshPairedDevices,
                                      icon: _isRefreshingPaired
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.refresh),
                                      tooltip: "Làm mới thiết bị đã ghép nối",
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Flexible(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _pairedDevices.length,
                                    itemBuilder: (context, index) {
                                      return _buildDeviceItem(
                                          _pairedDevices[index]);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Discover devices section
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      l10n.bluetoothDevices,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: ElevatedButton.icon(
                                      onPressed: _isDiscovering
                                          ? null
                                          : _discoverDevices,
                                      icon: _isDiscovering
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.search, size: 16),
                                      label: Text(
                                        _isDiscovering
                                            ? l10n.discovering
                                            : l10n.discoverDevices,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Discovered devices
                              Flexible(
                                child: _discoveredDevices.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _discoveredDevices.length,
                                        itemBuilder: (context, index) {
                                          return _buildDeviceItem(
                                              _discoveredDevices[index]);
                                        },
                                      )
                                    : !_isDiscovering
                                        ? Container(
                                            padding: const EdgeInsets.all(32),
                                            child: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.bluetooth_disabled,
                                                    size: 48,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    l10n.noDevicesFound,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                              ),
                            ],
                          ),
              ),
            ),

            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
